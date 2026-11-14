class WorkspacesController < ApplicationController
  before_action :load_workspace, only: :show

  def index
    @workspaces = current_user.workspaces.order(:name)
  end

  def new
    @workspace = Workspace.new
  end

  def create
    @workspace = Workspaces::Create.call(owner: current_user, name: workspace_params[:name])
    redirect_to workspace_path(@workspace.slug), notice: "Workspace created."
  rescue ActiveRecord::RecordInvalid => error
    @workspace = error.record.is_a?(Workspace) ? error.record : Workspace.new(workspace_params)
    @workspace.errors.add(:base, error.message) if @workspace.errors.empty?
    render :new, status: :unprocessable_entity
  end

  def show
    authorize Current.workspace, :show?
  end

  private

  def workspace_params
    params.require(:workspace).permit(:name)
  end
end
