class DashboardController < ApplicationController
  skip_before_action :require_authentication, only: :index

  def index
    if authenticated?
      @workspaces = current_user.workspaces.order(:name)
    else
      @contact_message = ContactMessage.new
      render "home/index"
    end
  end
end
