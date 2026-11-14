require "rails_helper"
require_relative "../support/sample_data"

RSpec.describe "Workspace invitations", type: :request do
  include SampleData

  it "allows an owner to invite an editor, then accept using the invited account" do
    owner = create_user(email: "owner@example.test")
    workspace = create_workspace_for(owner)
    sign_in(owner)
    expect do
      post workspace_invitations_path(workspace.slug), params: { workspace_invitation: {
        email: "editor@example.test", role: "editor"
      } }
    end.to change(WorkspaceInvitation, :count).by(1)
    invitation = WorkspaceInvitation.last
    expect(response).to redirect_to(workspace_memberships_path(workspace.slug))
    expect(invitation.raw_token).to be_nil # never persisted as plaintext
    perform_enqueued_jobs
    email = ActionMailer::Base.deliveries.last
    expect(email.to).to eq(["editor@example.test"])
    raw_token = email.body.decoded[%r{/accept-invitation/([A-Za-z0-9_-]+)}, 1]
    expect(raw_token).to be_present

    delete session_path
    editor = create_user(email: "editor@example.test")
    sign_in(editor)
    post accept_invitation_path(token: raw_token)
    expect(response).to redirect_to(workspace_path(workspace.slug))
    expect(editor.memberships.find_by!(workspace: workspace)).to be_editor
    expect(invitation.reload.accepted_at).to be_present
    post accept_invitation_path(token: raw_token)
    expect(response).to have_http_status(:gone)
  end

  it "rejects an uninvited email account" do
    owner = create_user(email: "owner@example.test")
    workspace = create_workspace_for(owner)
    invitation = WorkspaceInvitation.create!(workspace: workspace, invited_by: owner, email: "recipient@example.test", role: :agent)
    other = create_user(email: "other@example.test")
    sign_in(other)
    post accept_invitation_path(token: invitation.raw_token)
    expect(response).to have_http_status(:forbidden)
    expect(other.memberships).to be_empty
  end

  it "refuses editor invitations and owner role escalation" do
    editor = create_user
    workspace = create_workspace_for(editor, role: :editor)
    sign_in(editor)
    post workspace_invitations_path(workspace.slug), params: { workspace_invitation: { email: "x@example.test", role: "agent" } }
    expect(response).to have_http_status(:forbidden)
    expect(WorkspaceInvitation.count).to eq(0)

    editor.memberships.find_by!(workspace: workspace).update!(role: :owner)
    post workspace_invitations_path(workspace.slug), params: { workspace_invitation: { email: "x@example.test", role: "owner" } }
    expect(response).to have_http_status(:unprocessable_entity)
    expect(WorkspaceInvitation.count).to eq(0)
  end
end
