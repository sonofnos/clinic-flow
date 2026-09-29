require "rails_helper"

RSpec.describe "Patients", type: :request do
  let(:staff) { create(:user, :admin) }
  let(:provider_user) { create(:user, :provider) }

  describe "POST /api/v1/patients" do
    it "creates a patient for staff" do
      post "/api/v1/patients",
        params: { name: "New Patient", date_of_birth: "1999-01-01", email: "new@example.com" },
        headers: auth_headers(staff)

      expect(response).to have_http_status(:created)
    end

    it "forbids a provider-role user from creating a patient" do
      post "/api/v1/patients",
        params: { name: "New Patient", date_of_birth: "1999-01-01" },
        headers: auth_headers(provider_user)

      expect(response).to have_http_status(:forbidden)
    end
  end

  describe "GET /api/v1/patients/:id" do
    it "is readable by any authenticated user" do
      patient = create(:patient)

      get "/api/v1/patients/#{patient.id}", headers: auth_headers(provider_user)

      expect(response).to have_http_status(:ok)
    end
  end
end
