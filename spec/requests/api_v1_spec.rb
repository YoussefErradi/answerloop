require "rails_helper"
require_relative "../support/sample_data"

RSpec.describe "API v1", type: :request do
  include SampleData

  it "responds with a JSON 401 when signed out" do
    get "/api/v1/me"
    expect(response).to have_http_status(:unauthorized)
    expect(response.parsed_body.dig("error", "code")).to eq("unauthenticated")
  end

  it "returns the signed-in user, and creates a workspace with owner role" do
    owner = create_user
    sign_in(owner)
    get "/api/v1/me"
    expect(response.parsed_body.dig("data", "email")).to eq(owner.email_address)
    post "/api/v1/workspaces", params: { workspace: { name: "API Workspace", role: "admin" } }, as: :json
    expect(response).to have_http_status(:created)
    expect(owner.memberships.last).to be_owner
    get "/api/v1/workspaces"
    expect(response.parsed_body.fetch("data").length).to eq(1)
  end

  it "does not reveal memberships belonging to another workspace" do
    owner = create_user(email: "owner@example.test")
    workspace = create_workspace_for(owner)
    outsider = create_user(email: "outsider@example.test")
    sign_in(outsider)
    get "/api/v1/workspaces/#{workspace.slug}/memberships"
    expect(response).to have_http_status(:not_found)
  end

  it "forbids an agent from listing workspace members" do
    agent = create_user
    workspace = create_workspace_for(agent, role: :agent)
    sign_in(agent)
    get "/api/v1/workspaces/#{workspace.slug}/memberships"
    expect(response).to have_http_status(:forbidden)
  end
end
