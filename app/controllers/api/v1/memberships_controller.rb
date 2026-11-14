module Api
  module V1
    class MembershipsController < BaseController
      def index
        authorize api_workspace, :manage_members?
        data = api_workspace.memberships.includes(:user).map do |membership|
          { id: membership.id, email: membership.user.email_address, role: membership.role }
        end
        render json: { data: data }
      end
    end
  end
end
