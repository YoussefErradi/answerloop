class HelpController < ApplicationController
  skip_before_action :require_authentication
  before_action :load_public_workspace

  def index
    @categories = @workspace.categories.order(:position, :name)
    @category_articles = @workspace.articles.publicly_visible.where.not(category_id: nil).order(published_at: :desc).group_by(&:category_id)
    @articles = @workspace.articles.publicly_visible.includes(:category).order(published_at: :desc).limit(12)
  end

  def search
    @query = params[:q].to_s.strip.first(150)
    @articles = @workspace.articles.publicly_visible.search(@query).limit(30).to_a
    @workspace.search_events.create!(query: @query, result_count: @articles.length) if @query.present?
  end

  def article
    @article = @workspace.articles.publicly_visible.find_by!(slug: params[:slug])
  end

  private

  def load_public_workspace
    @workspace = Workspace.find_by!(slug: params[:workspace_slug])
  end
end
