class ArticlePolicy < ApplicationPolicy
  def index? = member?
  def show? = member?
  def preview? = member?
  def create? = editor?
  def update? = editor?
  def destroy? = editor?

  private

  def membership
    @membership ||= user&.memberships&.find_by(workspace_id: record.workspace_id)
  end

  def member? = membership.present?
  def editor? = membership && !membership.agent?
end
