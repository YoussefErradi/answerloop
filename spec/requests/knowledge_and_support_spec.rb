require "rails_helper"
require_relative "../support/sample_data"

RSpec.describe "Knowledge and support", type: :request do
  include SampleData
  include ActiveJob::TestHelper

  let(:owner) { create_user }
  let(:workspace) { create_workspace_for(owner) }

  it "publishes a rich article, searches it, and hides drafts" do
    workspace
    sign_in(owner)
    post workspace_categories_path(workspace.slug), params: { category: { name: "Billing" } }
    expect(response).to redirect_to(workspace_categories_path(workspace.slug))
    category = workspace.categories.last

    post workspace_articles_path(workspace.slug), params: { article: {
      title: "Update your invoice", summary: "Billing help", category_id: category.id,
      body: "<div>Change your invoice details from Settings.</div>", status: "published"
    } }
    expect(response).to have_http_status(:redirect)
    article = workspace.articles.last
    expect(article).to be_published
    expect(article.search_body).to include("invoice details")

    get help_article_path(workspace.slug, article.slug)
    expect(response).to have_http_status(:ok)
    expect(response.body).to include("Update your invoice")
    get help_search_path(workspace.slug), params: { q: "invoice" }
    expect(response.body).to include("Update your invoice")
    expect(workspace.search_events.last.result_count).to eq(1)

    article.update!(status: :draft)
    get help_article_path(workspace.slug, article.slug)
    expect(response).to have_http_status(:not_found)
    get help_search_path(workspace.slug), params: { q: "invoice" }
    expect(response.body).not_to include("Update your invoice")
    expect(workspace.search_events.last.result_count).to eq(0)
  end

  it "keeps editing and ticket work within the assigned workspace and role" do
    workspace
    outsider = create_user(email: "outsider@example.test")
    other_workspace = create_workspace_for(outsider, name: "Other")
    other_article = other_workspace.articles.create!(title: "Private", body: "Secret", author: outsider)
    contact = other_workspace.customer_contacts.create!(name: "Customer", email: "customer@example.test")
    other_ticket = other_workspace.tickets.create!(subject: "Private request", customer_contact: contact)

    sign_in(owner)
    get workspace_article_path(workspace.slug, other_article)
    expect(response).to have_http_status(:not_found)
    get workspace_ticket_path(workspace.slug, other_ticket)
    expect(response).to have_http_status(:not_found)

    agent = create_user(email: "agent@example.test")
    Membership.create!(workspace: workspace, user: agent, role: :agent)
    delete session_path
    sign_in(agent)
    get new_workspace_article_path(workspace.slug)
    expect(response).to have_http_status(:forbidden)
    get workspace_tickets_path(workspace.slug)
    expect(response).to have_http_status(:ok)
  end

  it "accepts customer tickets, exchanges one-time links, and separates notes from replies" do
    workspace
    perform_enqueued_jobs do
      post help_tickets_path(workspace.slug), params: { ticket: {
        name: "Customer", email: "customer@example.test", subject: "Need help", body: "Please help me"
      } }
    end
    expect(response).to redirect_to(help_path(workspace.slug))
    ticket = workspace.tickets.last
    expect(ticket.ticket_messages.count).to eq(1)
    expect(workspace.audit_events.last.action).to eq("ticket.created")
    expect(ActionMailer::Base.deliveries.map(&:to).flatten).to include("customer@example.test")

    mail = ActionMailer::Base.deliveries.find { |delivery| delivery.to == ["customer@example.test"] }
    token = mail.body.to_s[%r{/help/ticket-access/([^\s]+)}, 1]
    expect(token).to be_present
    get exchange_help_ticket_access_path(token)
    expect(response).to redirect_to(help_ticket_path(workspace.slug, ticket))
    get exchange_help_ticket_access_path(token)
    expect(response).to have_http_status(:not_found)
    get help_ticket_path(workspace.slug, ticket)
    expect(response.body).to include("Please help me")

    post help_ticket_replies_path(workspace.slug, ticket), params: { ticket_message: { body: "Any update?", kind: "note" } }
    expect(response).to redirect_to(help_ticket_path(workspace.slug, ticket))
    expect(ticket.ticket_messages.last).to be_reply
    expect(ticket.ticket_messages.last.author).to be_nil

    sign_in(owner)
    post workspace_ticket_ticket_messages_path(workspace.slug, ticket), params: { ticket_message: { body: "Internal only", kind: "note" } }
    expect(response).to redirect_to(workspace_ticket_path(workspace.slug, ticket))
    get help_ticket_path(workspace.slug, ticket)
    expect(response.body).not_to include("Internal only")
  end

  it "shows workspace analytics only to administrators" do
    workspace
    workspace.search_events.create!(query: "missing", result_count: 0)
    sign_in(owner)
    get workspace_path(workspace.slug)
    expect(response).to have_http_status(:ok)
    expect(response.body).to include("View analytics")
    get workspace_analytics_path(workspace.slug)
    expect(response).to have_http_status(:ok)
    expect(response.body).to include("Searches with no results")

    editor = create_user(email: "editor@example.test")
    Membership.create!(workspace: workspace, user: editor, role: :editor)
    delete session_path
    sign_in(editor)
    get workspace_analytics_path(workspace.slug)
    expect(response).to have_http_status(:forbidden)
  end

  it "lets support staff create tickets and maintain contacts" do
    workspace
    sign_in(owner)
    get new_workspace_ticket_path(workspace.slug)
    expect(response).to have_http_status(:ok)
    post workspace_tickets_path(workspace.slug), params: { ticket: {
      name: "Jane Customer", email: "jane@example.test", subject: "Account question",
      body: "Here is the answer", priority: "normal", assignee_id: owner.id
    } }
    ticket = workspace.tickets.last
    expect(response).to redirect_to(workspace_ticket_path(workspace.slug, ticket))
    expect(ticket.assignee).to eq(owner)
    expect(ticket.ticket_messages.last.author).to eq(owner)

    get workspace_customer_contacts_path(workspace.slug)
    expect(response.body).to include("Jane Customer")
    patch workspace_customer_contact_path(workspace.slug, ticket.customer_contact), params: {
      customer_contact: { name: "Jane Updated", email: "jane@example.test" }
    }
    expect(response).to have_http_status(:redirect)
    expect(ticket.customer_contact.reload.name).to eq("Jane Updated")

    old_link = TicketAccessLink.issue!(ticket)
    patch workspace_customer_contact_path(workspace.slug, ticket.customer_contact), params: {
      customer_contact: { name: "Jane Updated", email: "jane.new@example.test" }
    }
    expect(response).to have_http_status(:redirect)
    expect(TicketAccessLink.consume!(old_link)).to be_nil
  end
end
