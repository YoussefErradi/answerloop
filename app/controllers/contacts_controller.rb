class ContactsController < ApplicationController
  skip_before_action :require_authentication
  rate_limit to: 5, within: 1.hour, only: :create,
    with: -> { redirect_to root_path(anchor: "contact"), alert: "Please try again later." }

  def create
    @contact_message = ContactMessage.new(contact_params)
    if @contact_message.website.present?
      redirect_to root_path(anchor: "contact"), notice: "Thanks for reaching out. We'll be in touch."
    elsif @contact_message.valid?
      ContactMailer.with(contact_message: @contact_message).inquiry.deliver_now
      redirect_to root_path(anchor: "contact"), notice: "Thanks for reaching out. We'll be in touch."
    else
      render "home/index", status: :unprocessable_entity
    end
  end

  private

  def contact_params
    params.require(:contact_message).permit(:name, :email, :message, :website)
  end
end
