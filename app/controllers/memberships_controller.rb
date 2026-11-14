class MembershipsController < ApplicationController
  before_action :load_workspace

  def index
    authorize Current.workspace, :manage_members?
    @memberships = Current.workspace.memberships.includes(:user).order(:created_at)
  end
end
