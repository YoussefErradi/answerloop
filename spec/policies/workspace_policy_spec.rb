require "rails_helper"
require_relative "../support/sample_data"

RSpec.describe WorkspacePolicy, type: :policy do
  include SampleData

  it "allows the owner to manage members" do
    owner = create_user
    workspace = create_workspace_for(owner)
    expect(described_class.new(owner, workspace).manage_members?).to be(true)
  end

  it "denies an editor membership management" do
    editor = create_user
    workspace = create_workspace_for(editor, role: :editor)
    expect(described_class.new(editor, workspace).manage_members?).to be(false)
  end

  it "denies users outside the workspace" do
    owner = create_user
    outsider = create_user(email: "outsider@example.test")
    workspace = create_workspace_for(owner)
    expect(described_class.new(outsider, workspace).show?).to be(false)
  end
end
