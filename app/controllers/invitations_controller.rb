class InvitationsController < ApplicationController
  before_action :load_workspace
  before_action :authorize_invitation

  def new
    @invitation = Current.workspace.workspace_invitations.new(role: :agent)
  end

  def create
    permitted = params.require(:workspace_invitation).permit(:email)
    requested_role = params.require(:workspace_invitation)[:role].to_s
    @invitation = Current.workspace.workspace_invitations.new(email: permitted[:email])
    @invitation.invited_by = current_user
    unless WorkspaceInvitation.roles.key?(requested_role)
      @invitation.errors.add(:role, "must be Admin, Editor, or Support agent")
      return render :new, status: :unprocessable_entity
    end
    @invitation.role = requested_role
    if @invitation.save
      WorkspaceInvitationMailer.with(invitation: @invitation, token: @invitation.raw_token).invite.deliver_later
      redirect_to workspace_memberships_path(Current.workspace.slug), notice: "Invitation sent."
    else
      render :new, status: :unprocessable_entity
    end
  end

  private

  def authorize_invitation
    authorize Current.workspace, :invite?
  end
end
