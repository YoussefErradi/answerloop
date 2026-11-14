require "rails_helper"
require_relative "../support/sample_data"

RSpec.describe "Sessions", type: :request do
  include SampleData

  it "authenticates and signs out a user" do
    user = create_user
    sign_in(user)
    get root_path
    expect(response).to have_http_status(:ok)
    delete session_path
    expect(response).to redirect_to(new_session_path)
    get root_path
    expect(response).to have_http_status(:ok)
    expect(response.body).to include("Fewer repeat questions.")
  end

  it "rejects incorrect credentials" do
    user = create_user
    post session_path, params: { email_address: user.email_address, password: "wrong" }
    expect(response).to have_http_status(:unprocessable_entity)
  end
end
