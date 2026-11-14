require "rails_helper"

RSpec.describe Workspace, type: :model do
  it "generates a lowercase unique slug" do
    first = Workspace.create!(name: "Help Desk")
    second = Workspace.create!(name: "Help Desk")
    expect(first.slug).to match(/\Ahelp-desk-[a-f0-9]{8}\z/)
    expect(first.slug).not_to eq(second.slug)
  end

  it "requires a name" do
    expect(Workspace.new(name: "")).not_to be_valid
  end
end
