class TicketsController < ApplicationController
  before_action :load_workspace
  before_action :set_ticket, only: %i[show update]

  def index
    authorize Ticket.new(workspace: current_workspace)
    @status = params[:status].presence_in(Ticket.statuses.keys)
    @tickets = current_workspace.tickets.includes(:customer_contact, :assignee).order(created_at: :desc)
    @tickets = @tickets.where(status: @status) if @status
    @tickets = @tickets.limit(100)
  end

  def show
    authorize @ticket
    @messages = @ticket.ticket_messages.includes(:author).order(:created_at)
    @message = @ticket.ticket_messages.new
    @assignees = @ticket.staff_members
  end

  def new
    @ticket = current_workspace.tickets.new
    authorize @ticket, :create?
  end

  def create
    authorize Ticket.new(workspace: current_workspace), :create?
    input = params.require(:ticket).permit(:subject, :body, :name, :email, :priority, :assignee_id)
    @contact = current_workspace.customer_contacts.find_or_initialize_by(email: input[:email].to_s.strip.downcase)
    @contact.name = input[:name] if @contact.new_record?
    @ticket = current_workspace.tickets.new(subject: input[:subject], customer_contact: @contact,
      priority: input[:priority], assignee_id: input[:assignee_id])
    message = @ticket.ticket_messages.new(body: input[:body], kind: :reply, author: current_user)

    if @contact.valid? && @ticket.valid? && message.valid?
      Ticket.transaction do
        @contact.save!
        @ticket.save!
        message.save!
        current_workspace.audit_events.create!(ticket: @ticket, actor: current_user, action: "ticket.created")
      end
      TicketMailer.staff_reply(@ticket, TicketAccessLink.issue!(@ticket)).deliver_later
      redirect_to workspace_ticket_path(current_workspace.slug, @ticket), notice: "Ticket created."
    else
      @ticket.errors.add(:base, @contact.errors.full_messages.to_sentence) if @contact.errors.any?
      @ticket.errors.add(:body, message.errors.full_messages.to_sentence) if message.errors.any?
      render :new, status: :unprocessable_entity
    end
  end

  def update
    authorize @ticket
    permitted = params.require(:ticket).permit(:status, :priority, :assignee_id)
    if @ticket.update(permitted)
      current_workspace.audit_events.create!(ticket: @ticket, actor: current_user, action: "ticket.updated", metadata: permitted.to_h)
      redirect_to workspace_ticket_path(current_workspace.slug, @ticket), notice: "Ticket updated."
    else
      show
      render :show, status: :unprocessable_entity
    end
  end

  private

  def set_ticket
    @ticket = current_workspace.tickets.find(params[:id])
  end
end
