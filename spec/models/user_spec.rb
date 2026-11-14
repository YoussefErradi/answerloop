require "rails_helper"
require_relative "../support/sample_data"

RSpec.describe User, type: :model do
  include SampleData

  it "normalizes email addresses" do
    user = create_user(email: "  DEVELOPER@Example.Test ")
    expect(user.email_address).to eq("developer@example.test")
  end

  it "rejects case-insensitive duplicates" do
    create_user(email: "dev@example.test")
    duplicate = User.new(email_address: "DEV@EXAMPLE.TEST", password: "a-long-test-password")
    expect(duplicate).not_to be_valid
  end

  it "rejects short passwords" do
    user = User.new(email_address: "new@example.test", password: "short", password_confirmation: "short")
    expect(user).not_to be_valid
  end
end
