class TicketPolicy < ApplicationPolicy
  def index? = support_member?
  def show? = support_member?
  def update? = support_member?
  def create? = support_member?
  def create_message? = support_member?

  private

  def support_member?
    membership = user&.memberships&.find_by(workspace_id: record.workspace_id)
    membership.present? && !membership.editor?
  end
end
