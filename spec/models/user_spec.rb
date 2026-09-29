require "rails_helper"

RSpec.describe User, type: :model do
  it "downcases email before saving" do
    user = create(:user, email: "Mixed.Case@Example.com")

    expect(user.reload.email).to eq("mixed.case@example.com")
  end

  it "requires a unique email regardless of case" do
    create(:user, email: "dupe@example.com")
    duplicate = build(:user, email: "DUPE@example.com")

    expect(duplicate).not_to be_valid
  end

  it "authenticates with the correct password" do
    user = create(:user, password: "correcthorse")

    expect(user.authenticate("correcthorse")).to eq(user)
    expect(user.authenticate("wrong")).to be false
  end
end
