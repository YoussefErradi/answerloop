require "rails_helper"

RSpec.describe "Public landing and contact", type: :request do
  it "shows the landing page to visitors" do
    get root_path

    expect(response).to have_http_status(:ok)
    expect(response.body).to include("Fewer repeat questions.")
    expect(response.body).to include("How it works")
    expect(response.body).to include("ABOUT US")
    expect(response.body).to include("Contact")
  end

  it "accepts a contact inquiry and delivers it to the test inbox" do
    expect do
      post contact_path, params: { contact_message: {
        name: "Alex Morgan", email: "alex@example.test",
        message: "I'd like to learn more about AnswerLoop."
      } }
    end.to change(ActionMailer::Base.deliveries, :count).by(1)

    expect(response).to redirect_to(root_path(anchor: "contact"))
    email = ActionMailer::Base.deliveries.last
    expect(email.to).to eq(["hello@answerloop.local"])
    expect(email.reply_to).to eq(["alex@example.test"])
    expect(email.body.decoded).to include("I'd like to learn more")
  end

  it "rejects invalid inquiries without delivering mail" do
    post contact_path, params: { contact_message: {
      name: "Alex", email: "not-an-email", message: "short"
    } }

    expect(response).to have_http_status(:unprocessable_entity)
    expect(response.body).to include("Please check your message")
    expect(ActionMailer::Base.deliveries).to be_empty
  end

  it "does not deliver honeypot submissions" do
    post contact_path, params: { contact_message: {
      name: "Alex", email: "alex@example.test", message: "This is a valid looking message.",
      website: "https://spam.example"
    } }

    expect(response).to redirect_to(root_path(anchor: "contact"))
    expect(ActionMailer::Base.deliveries).to be_empty
  end
end
