class WorkspaceInvitationMailer < ApplicationMailer
  def invite
    @invitation = params.fetch(:invitation)
    @url = accept_invitation_url(token: params.fetch(:token))
    mail(to: @invitation.email, subject: "You're invited to #{@invitation.workspace.name} on AnswerLoop")
  end
end
