class WorkspacePolicy < ApplicationPolicy
  def show?
    membership.present?
  end

  def manage_members?
    membership&.can_manage_members? || false
  end

  def invite?
    manage_members?
  end

  private

  def membership
    return nil unless user
    @membership ||= user.memberships.find_by(workspace_id: record.id)
  end
end
