class ArticlesController < ApplicationController
  before_action :load_workspace
  before_action :set_article, only: %i[show edit update destroy preview]

  def index
    authorize Article.new(workspace: current_workspace)
    @articles = current_workspace.articles.includes(:category, :author).order(updated_at: :desc)
  end

  def show
    authorize @article
  end

  def preview
    authorize @article
    render :show
  end

  def new
    @article = current_workspace.articles.new
    authorize @article, :create?
  end

  def create
    @article = current_workspace.articles.new(article_params.merge(author: current_user))
    authorize @article
    if @article.save
      redirect_to workspace_article_path(current_workspace.slug, @article), notice: "Article saved."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    authorize @article
  end

  def update
    authorize @article
    if @article.update(article_params)
      redirect_to workspace_article_path(current_workspace.slug, @article), notice: "Article updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    authorize @article
    @article.destroy!
    redirect_to workspace_articles_path(current_workspace.slug), notice: "Article deleted."
  end

  private

  def set_article
    @article = current_workspace.articles.find(params[:id])
  end

  def article_params
    allowed = params.require(:article).permit(:title, :summary, :body, :status, :category_id)
    if allowed[:category_id].present?
      allowed[:category_id] = current_workspace.categories.find(allowed[:category_id]).id
    end
    allowed
  end
end
