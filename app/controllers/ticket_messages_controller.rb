class TicketMessagesController < ApplicationController
  before_action :load_workspace

  def create
    @ticket = current_workspace.tickets.find(params[:ticket_id])
    authorize @ticket, :create_message?
    @message = @ticket.ticket_messages.new(params.require(:ticket_message).permit(:body, :kind).merge(author: current_user))
    if @message.save
      @ticket.update!(status: :pending) if @message.reply? && @ticket.open?
      current_workspace.audit_events.create!(ticket: @ticket, actor: current_user, action: "ticket.#{@message.kind}")
      TicketMailer.staff_reply(@ticket, TicketAccessLink.issue!(@ticket)).deliver_later if @message.reply?
      redirect_to workspace_ticket_path(current_workspace.slug, @ticket), notice: "Message added."
    else
      @messages = @ticket.ticket_messages.includes(:author).order(:created_at)
      @assignees = @ticket.staff_members
      render "tickets/show", status: :unprocessable_entity
    end
  end
end
