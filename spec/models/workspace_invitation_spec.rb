require "rails_helper"
require_relative "../support/sample_data"

RSpec.describe WorkspaceInvitation, type: :model do
  include SampleData

  it "stores a digest rather than the raw token" do
    owner = create_user
    workspace = create_workspace_for(owner)
    invitation = WorkspaceInvitation.create!(workspace: workspace, invited_by: owner, email: "joiner@example.test", role: :editor)
    expect(invitation.token_digest).not_to eq(invitation.raw_token)
    expect(WorkspaceInvitation.find_using_token(invitation.raw_token)).to eq(invitation)
  end
end
