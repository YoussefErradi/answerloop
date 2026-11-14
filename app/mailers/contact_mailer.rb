class ContactMailer < ApplicationMailer
  def inquiry
    @contact_message = params.fetch(:contact_message)
    mail(
      to: ENV.fetch("CONTACT_EMAIL", "hello@answerloop.local"),
      reply_to: @contact_message.email,
      subject: "New AnswerLoop contact inquiry"
    )
  end
end
