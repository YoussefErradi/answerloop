module Api
  module V1
    class WorkspacesController < BaseController
      def index
        data = current_user.workspaces.order(:name).map do |workspace|
          { id: workspace.id, name: workspace.name, slug: workspace.slug }
        end
        render json: { data: data }
      end

      def show
        authorize api_workspace, :show?
        render json: { data: {
          id: api_workspace.id, name: api_workspace.name,
          slug: api_workspace.slug
        } }
      end

      def create
        workspace = Workspaces::Create.call(owner: current_user, name: create_params[:name])
        render json: { data: { id: workspace.id, name: workspace.name, slug: workspace.slug } }, status: :created
      rescue ActiveRecord::RecordInvalid => error
        render json: { error: { code: "invalid", message: error.message } }, status: :unprocessable_entity
      end

      private

      def create_params
        params.require(:workspace).permit(:name)
      end
    end
  end
end
