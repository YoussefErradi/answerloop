class CategoriesController < ApplicationController
  before_action :load_workspace

  def index
    authorize Category.new(workspace: current_workspace)
    @categories = current_workspace.categories.order(:position, :name)
    @article_counts = current_workspace.articles.group(:category_id).count
    @category = current_workspace.categories.new
  end

  def create
    @category = current_workspace.categories.new(params.require(:category).permit(:name, :position))
    authorize @category
    if @category.save
      redirect_to workspace_categories_path(current_workspace.slug), notice: "Category created."
    else
      @categories = current_workspace.categories.order(:position, :name)
      @article_counts = current_workspace.articles.group(:category_id).count
      render :index, status: :unprocessable_entity
    end
  end

  def destroy
    @category = current_workspace.categories.find(params[:id])
    authorize @category
    @category.destroy!
    redirect_to workspace_categories_path(current_workspace.slug), notice: "Category removed."
  end
end
