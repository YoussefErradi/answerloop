class AnalyticsController < ApplicationController
  before_action :load_workspace

  def show
    authorize current_workspace, :show?, policy_class: AnalyticsPolicy
    @days = params[:days].to_i.presence_in([7, 30, 90]) || 30
    since = @days.days.ago
    @published_articles = current_workspace.articles.publicly_visible.count
    @draft_articles = current_workspace.articles.draft.count
    @new_tickets = current_workspace.tickets.where(created_at: since..).count
    @resolved_tickets = current_workspace.tickets.resolved.where(resolved_at: since..).count
    @open_tickets = current_workspace.tickets.open.count
    events = current_workspace.search_events.where(created_at: since..)
    @searches = events.count
    @zero_results = events.where(result_count: 0).count
    @top_queries = events.group(:query).order(Arel.sql("count_all DESC")).limit(10).count
    @ticket_statuses = current_workspace.tickets.group(:status).count
  end
end
