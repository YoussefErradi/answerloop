class TicketMailer < ApplicationMailer
  def access_link(ticket, token)
    @ticket = ticket
    @url = exchange_help_ticket_access_url(token: token)
    mail(to: ticket.customer_contact.email, subject: "Access your AnswerLoop ticket ##{ticket.id}")
  end

  def new_ticket(ticket, recipient)
    @ticket = ticket
    @url = workspace_ticket_url(ticket.workspace.slug, ticket)
    mail(to: recipient.email_address, subject: "New support ticket ##{ticket.id}: #{ticket.subject}")
  end

  def customer_reply(ticket, recipient)
    @ticket = ticket
    @url = workspace_ticket_url(ticket.workspace.slug, ticket)
    mail(to: recipient.email_address, subject: "Customer replied to ticket ##{ticket.id}")
  end

  def staff_reply(ticket, token)
    @ticket = ticket
    @url = exchange_help_ticket_access_url(token: token)
    mail(to: ticket.customer_contact.email, subject: "Update on your ticket ##{ticket.id}")
  end
end
