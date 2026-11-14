require "rails_helper"

RSpec.describe "Registration", type: :request do
  it "creates a user and starts an authenticated session" do
    post registration_path, params: { user: {
      email_address: "new@example.test", password: "a-long-test-password",
      password_confirmation: "a-long-test-password"
    } }
    expect(response).to redirect_to(new_workspace_path)
    expect(User.find_by(email_address: "new@example.test")).to be_present
    follow_redirect!
    expect(response).to have_http_status(:ok)
  end

  it "does not allow setting workspace roles through registration" do
    post registration_path, params: { user: {
      email_address: "new@example.test", password: "a-long-test-password",
      password_confirmation: "a-long-test-password", role: "owner"
    } }
    expect(Membership.count).to eq(0)
  end
end
