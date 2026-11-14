module Workspaces
  class Create
    def self.call(owner:, name:)
      Workspace.transaction do
        workspace = Workspace.create!(name: name)
        workspace.memberships.create!(user: owner, role: :owner)
        workspace
      end
    end
  end
end
