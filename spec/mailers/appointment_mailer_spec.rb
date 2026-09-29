require "rails_helper"

RSpec.describe AppointmentMailer, type: :mailer do
  describe "reminder" do
    let(:appointment) { create(:appointment) }
    let(:mail) { AppointmentMailer.reminder(appointment) }

    it "renders the headers" do
      expect(mail.subject).to eq("Reminder: your appointment tomorrow")
      expect(mail.to).to eq([ appointment.patient.email ])
    end

    it "renders the body" do
      expect(mail.body.encoded).to match(appointment.patient.name)
    end
  end
end
