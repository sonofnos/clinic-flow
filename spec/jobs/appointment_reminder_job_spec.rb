require "rails_helper"

RSpec.describe AppointmentReminderJob, type: :job do
  include ActiveJob::TestHelper

  it "queues a reminder email for a scheduled appointment" do
    appointment = create(:appointment)

    perform_enqueued_jobs do
      described_class.perform_now(appointment.id)
    end

    expect(ActionMailer::Base.deliveries.last.to).to eq([ appointment.patient.email ])
  end

  it "does nothing if the appointment was cancelled before the reminder fired" do
    appointment = create(:appointment)
    appointment.cancel!

    expect { described_class.perform_now(appointment.id) }
      .not_to change { ActionMailer::Base.deliveries.count }
  end

  it "does nothing if the appointment no longer exists" do
    expect { described_class.perform_now(-1) }.not_to raise_error
  end
end
