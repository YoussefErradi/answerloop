class AnalyticsPolicy < ApplicationPolicy
  def show?
    membership = user&.memberships&.find_by(workspace_id: record.id)
    membership&.can_manage_members? || false
  end
end
