require "rails_helper"

RSpec.describe Appointment, type: :model do
  describe "validations" do
    it "requires ends_at to be after starts_at" do
      appointment = build(:appointment, starts_at: Time.zone.parse("2027-01-01 10:00"),
                                         ends_at: Time.zone.parse("2027-01-01 09:00"))

      expect(appointment).not_to be_valid
      expect(appointment.errors[:ends_at]).to include("must be after the start time")
    end

    it "requires starts_at to be in the future on create" do
      appointment = build(:appointment, starts_at: 1.day.ago, ends_at: 1.day.ago + 30.minutes)

      expect(appointment).not_to be_valid
      expect(appointment.errors[:starts_at]).to include("must be in the future")
    end
  end

  describe ".book!" do
    let(:provider) { create(:provider) }
    let(:patient) { create(:patient) }
    let(:starts_at) { 1.day.from_now.change(hour: 10) }
    let(:ends_at) { starts_at + 30.minutes }

    it "creates the appointment when the slot is free" do
      appointment = Appointment.book!(provider: provider, patient: patient, starts_at: starts_at, ends_at: ends_at)

      expect(appointment).to be_persisted
      expect(appointment).to be_scheduled
    end

    it "rejects a second booking that overlaps an existing one" do
      Appointment.book!(provider: provider, patient: patient, starts_at: starts_at, ends_at: ends_at)
      other_patient = create(:patient)

      expect {
        Appointment.book!(
          provider: provider,
          patient: other_patient,
          starts_at: starts_at + 10.minutes,
          ends_at: ends_at + 10.minutes
        )
      }.to raise_error(Appointment::SlotUnavailableError)
    end

    it "allows rebooking a slot that was cancelled" do
      first = Appointment.book!(provider: provider, patient: patient, starts_at: starts_at, ends_at: ends_at)
      first.cancel!(reason: "patient request")

      other_patient = create(:patient)
      second = Appointment.book!(provider: provider, patient: other_patient, starts_at: starts_at, ends_at: ends_at)

      expect(second).to be_persisted
    end

    # Regression test for a real race: two requests booking the same provider
    # for an overlapping slot at the same time, each on its own DB connection.
    # A row lock inside a single transaction can't stop this by itself --
    # closing it needs the DB-level EXCLUDE constraint from the migration too.
    it "allows only one booking to win when two requests race for the same slot", :no_transaction do
      other_patient = create(:patient)
      results = Queue.new

      threads = [ patient, other_patient ].map do |p|
        Thread.new do
          ActiveRecord::Base.connection_pool.with_connection do
            Appointment.book!(provider: provider, patient: p, starts_at: starts_at, ends_at: ends_at)
            results << :booked
          rescue Appointment::SlotUnavailableError
            results << :rejected
          end
        end
      end
      threads.each(&:join)

      outcomes = Array.new(2) { results.pop }
      expect(outcomes).to contain_exactly(:booked, :rejected)
      expect(Appointment.where(provider: provider, status: :scheduled).count).to eq(1)
    end
  end
end
