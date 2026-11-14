class CustomerContactsController < ApplicationController
  before_action :load_workspace

  def index
    authorize CustomerContact.new(workspace: current_workspace)
    @contacts = current_workspace.customer_contacts.order(:name).limit(100)
    @ticket_counts = current_workspace.tickets.where(customer_contact_id: @contacts.map(&:id)).group(:customer_contact_id).count
  end

  def show
    @contact = current_workspace.customer_contacts.find(params[:id])
    authorize @contact
    @tickets = @contact.tickets.order(created_at: :desc)
  end

  def update
    @contact = current_workspace.customer_contacts.find(params[:id])
    authorize @contact
    if @contact.update(params.require(:customer_contact).permit(:name, :email))
      if @contact.saved_change_to_email?
        TicketAccessLink.where(ticket_id: @contact.tickets.select(:id), used_at: nil).update_all(used_at: Time.current)
      end
      current_workspace.audit_events.create!(actor: current_user, action: "contact.updated", metadata: { contact_id: @contact.id })
      redirect_to workspace_customer_contact_path(current_workspace.slug, @contact), notice: "Contact updated."
    else
      @tickets = @contact.tickets.order(created_at: :desc)
      render :show, status: :unprocessable_entity
    end
  end
end
