require "rails_helper"
require_relative "../support/sample_data"

RSpec.describe "Workspace authorization", type: :request do
  include SampleData

  it "makes the creator an owner, ignoring any submitted role" do
    user = create_user
    sign_in(user)
    post workspaces_path, params: { workspace: { name: "Acme", role: "agent" } }
    workspace = Workspace.last
    expect(response).to redirect_to(workspace_path(workspace.slug))
    expect(workspace.memberships.find_by!(user: user)).to be_owner
  end

  it "returns not found for a workspace belonging to another user" do
    outsider = create_user(email: "outsider@example.test")
    private_workspace = create_workspace_for(outsider)
    signed_in = create_user(email: "signedin@example.test")
    sign_in(signed_in)
    get workspace_path(private_workspace.slug)
    expect(response).to have_http_status(:not_found)
    get workspace_memberships_path(private_workspace.slug)
    expect(response).to have_http_status(:not_found)
  end

  it "forbids an editor from reading team membership details" do
    user = create_user
    workspace = create_workspace_for(user, role: :editor)
    sign_in(user)
    get workspace_memberships_path(workspace.slug)
    expect(response).to have_http_status(:forbidden)
  end

  it "allows an admin to list members" do
    user = create_user
    workspace = create_workspace_for(user, role: :admin)
    sign_in(user)
    get workspace_memberships_path(workspace.slug)
    expect(response).to have_http_status(:ok)
  end
end
