class PublicTicketsController < ApplicationController
  skip_before_action :require_authentication
  before_action :load_public_workspace, except: :exchange
  before_action :set_ticket, only: %i[show request_access reply]

  def new
    @contact = CustomerContact.new
    @ticket = Ticket.new
  end

  def create
    input = params.require(:ticket).permit(:subject, :body, :name, :email)
    @contact = @workspace.customer_contacts.find_or_initialize_by(email: input[:email].to_s.strip.downcase)
    @contact.name = input[:name] if @contact.new_record?
    @ticket = @workspace.tickets.new(subject: input[:subject], customer_contact: @contact)
    message = @ticket.ticket_messages.new(body: input[:body], kind: :reply)

    if @contact.valid? && @ticket.valid? && message.valid?
      Ticket.transaction do
        @contact.save!
        @ticket.save!
        message.save!
        @workspace.audit_events.create!(ticket: @ticket, action: "ticket.created")
      end
      TicketMailer.access_link(@ticket, TicketAccessLink.issue!(@ticket)).deliver_later
      @ticket.staff_members.each { |user| TicketMailer.new_ticket(@ticket, user).deliver_later }
      redirect_to help_path(@workspace.slug), notice: "Ticket received. Check your email for a secure access link."
    else
      @ticket.errors.add(:base, @contact.errors.full_messages.to_sentence) if @contact.errors.any?
      @ticket.errors.add(:body, message.errors.full_messages.to_sentence) if message.errors.any?
      render :new, status: :unprocessable_entity
    end
  end

  def show
    return head :not_found unless customer_authorized?(@ticket)
    @messages = @ticket.ticket_messages.reply.order(:created_at)
  end

  def request_access
    email = params[:email].to_s.strip.downcase
    if ActiveSupport::SecurityUtils.secure_compare(@ticket.customer_contact.email, email)
      TicketMailer.access_link(@ticket, TicketAccessLink.issue!(@ticket)).deliver_later
    end
    redirect_to help_path(@workspace.slug), notice: "If the address matches, a new access link is on its way."
  end

  def exchange
    ticket = TicketAccessLink.consume!(params[:token])
    return head :not_found unless ticket
    cookies.encrypted[:customer_ticket] = {
      value: { ticket_id: ticket.id, contact_id: ticket.customer_contact_id, email: ticket.customer_contact.email },
      expires: 30.days.from_now, httponly: true, same_site: :lax, secure: Rails.env.production?
    }
    redirect_to help_ticket_path(ticket.workspace.slug, ticket), notice: "You can now view this ticket."
  end

  def reply
    return head :not_found unless customer_authorized?(@ticket)
    @message = @ticket.ticket_messages.new(body: params.require(:ticket_message).permit(:body)[:body], kind: :reply)
    if @message.save
      @ticket.update!(status: :open) unless @ticket.open?
      @workspace.audit_events.create!(ticket: @ticket, action: "ticket.customer_reply")
      @ticket.staff_members.each { |user| TicketMailer.customer_reply(@ticket, user).deliver_later }
      redirect_to help_ticket_path(@workspace.slug, @ticket), notice: "Reply sent."
    else
      @messages = @ticket.ticket_messages.reply.order(:created_at)
      render :show, status: :unprocessable_entity
    end
  end

  private

  def load_public_workspace
    @workspace = Workspace.find_by!(slug: params[:workspace_slug])
  end

  def set_ticket
    @ticket = @workspace.tickets.includes(:customer_contact).find(params[:id])
  end

  def customer_authorized?(ticket)
    access = cookies.encrypted[:customer_ticket]
    access.is_a?(Hash) && access["ticket_id"] == ticket.id && access["contact_id"] == ticket.customer_contact_id && access["email"] == ticket.customer_contact.email
  end
end
