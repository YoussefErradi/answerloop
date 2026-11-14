class ApplicationController < ActionController::Base
  include Authentication
  protect_from_forgery with: :exception
  include Pundit::Authorization

  helper_method :current_user, :current_workspace, :current_membership
  rescue_from Pundit::NotAuthorizedError, with: :access_denied

  private

  def current_user
    Current.user
  end

  def current_workspace
    Current.workspace
  end

  def current_membership
    Current.membership
  end

  def load_workspace
    # Crucial: find through the user's memberships, never Workspace.find(params[:id]).
    slug = params[:workspace_id] || params[:id]
    Current.workspace = current_user.workspaces.find_by!(slug: slug)
    Current.membership = current_user.memberships.find_by!(workspace_id: Current.workspace.id)
  end

  def access_denied
    head :forbidden
  end
end
