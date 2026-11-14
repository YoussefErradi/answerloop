module Api
  module V1
    class BaseController < ApplicationController
      private

      def require_authentication
        return if resume_session
        render json: { error: { code: "unauthenticated", message: "Sign in required." } }, status: :unauthorized
      end

      def access_denied
        render json: { error: { code: "forbidden", message: "Not permitted." } }, status: :forbidden
      end

      def api_workspace
        slug = params[:workspace_slug] || params[:slug]
        @api_workspace ||= current_user.workspaces.find_by!(slug: slug)
      end
    end
  end
end
