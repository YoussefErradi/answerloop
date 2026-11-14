class InvitationAcceptancesController < ApplicationController
  before_action :load_invitation

  def show
    unless @invitation.usable?
      return render plain: "Invitation expired or already used.", status: :gone
    end
    unless current_user.email_address == @invitation.email
      return render plain: "Sign in with the invited email address.", status: :forbidden
    end
  end

  def create
    unless current_user.email_address == @invitation.email
      return head :forbidden
    end
    @invitation.with_lock do
      unless @invitation.usable?
        return head :gone
      end
      Membership.find_or_create_by!(workspace: @invitation.workspace, user: current_user) do |member|
        member.role = @invitation.role
      end
      @invitation.update!(accepted_at: Time.current)
    end
    redirect_to workspace_path(@invitation.workspace.slug), notice: "You joined the workspace."
  end

  private

  def load_invitation
    @invitation = WorkspaceInvitation.find_using_token(params[:token])
    raise ActiveRecord::RecordNotFound unless @invitation
  end
end
