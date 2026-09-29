require "rails_helper"

RSpec.describe "Appointments", type: :request do
  let(:staff) { create(:user, :admin) }
  let(:provider_record) { create(:provider) }
  let(:patient_record) { create(:patient) }
  let(:starts_at) { 1.day.from_now.change(hour: 10) }
  let(:ends_at) { starts_at + 30.minutes }

  describe "POST /api/v1/appointments" do
    it "books an appointment for an authorized staff user" do
      post "/api/v1/appointments",
        params: {
          provider_id: provider_record.id,
          patient_id: patient_record.id,
          starts_at: starts_at,
          ends_at: ends_at
        },
        headers: auth_headers(staff)

      expect(response).to have_http_status(:created)
      expect(JSON.parse(response.body)["status"]).to eq("scheduled")
    end

    it "returns 409 when the slot is already booked" do
      Appointment.book!(provider: provider_record, patient: patient_record, starts_at: starts_at, ends_at: ends_at)
      other_patient = create(:patient)

      post "/api/v1/appointments",
        params: {
          provider_id: provider_record.id,
          patient_id: other_patient.id,
          starts_at: starts_at,
          ends_at: ends_at
        },
        headers: auth_headers(staff)

      expect(response).to have_http_status(:conflict)
    end

    it "rejects a provider-role user from booking directly" do
      provider_user = create(:user, :provider)

      post "/api/v1/appointments",
        params: {
          provider_id: provider_record.id,
          patient_id: patient_record.id,
          starts_at: starts_at,
          ends_at: ends_at
        },
        headers: auth_headers(provider_user)

      expect(response).to have_http_status(:forbidden)
    end

    it "returns 401 without a token" do
      post "/api/v1/appointments", params: { provider_id: provider_record.id }

      expect(response).to have_http_status(:unauthorized)
    end
  end

  describe "POST /api/v1/appointments/:id/cancel" do
    it "cancels an existing appointment and frees the slot" do
      appointment = Appointment.book!(provider: provider_record, patient: patient_record, starts_at: starts_at, ends_at: ends_at)

      post "/api/v1/appointments/#{appointment.id}/cancel",
        params: { reason: "patient request" },
        headers: auth_headers(staff)

      expect(response).to have_http_status(:ok)
      expect(appointment.reload).to be_cancelled
    end
  end
end
