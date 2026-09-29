require "rails_helper"

RSpec.describe "Sessions", type: :request do
  describe "POST /login" do
    let!(:user) { create(:user, email: "staff@example.com", password: "password123") }

    it "returns a token for valid credentials" do
      post "/login", params: { email: "staff@example.com", password: "password123" }

      expect(response).to have_http_status(:ok)
      body = JSON.parse(response.body)
      expect(body["token"]).to be_present
      expect(body["user"]["email"]).to eq("staff@example.com")
    end

    it "rejects invalid credentials" do
      post "/login", params: { email: "staff@example.com", password: "wrong" }

      expect(response).to have_http_status(:unauthorized)
    end
  end
end
