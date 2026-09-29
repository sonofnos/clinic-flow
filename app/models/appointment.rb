class Appointment < ApplicationRecord
  class SlotUnavailableError < StandardError; end

  belongs_to :provider
  belongs_to :patient

  enum :status, { scheduled: 0, completed: 1, cancelled: 2, no_show: 3 }, default: :scheduled

  validates :starts_at, presence: true
  validates :ends_at, presence: true
  validate :ends_after_starts
  validate :starts_in_future, on: :create

  after_create_commit :schedule_reminder

  # Books an appointment while guarding against double-booking a provider.
  #
  # A unique index can't express "no overlapping range", so correctness here
  # rests on two layers: a row lock on the provider for the duration of the
  # check-then-insert (closes the race between two app processes), and a
  # Postgres EXCLUDE constraint on the table itself (closes the race between
  # two *database connections* doing the same check-then-insert at once,
  # which a lock inside a single transaction cannot prevent by itself).
  def self.book!(provider:, patient:, starts_at:, ends_at:)
    transaction do
      provider.lock!

      overlapping = provider.appointments
                             .where(status: [ statuses[:scheduled], statuses[:completed] ])
                             .where("tsrange(starts_at, ends_at) && tsrange(?, ?)", starts_at, ends_at)
                             .exists?
      raise SlotUnavailableError, "Provider is already booked for that time" if overlapping

      create!(provider: provider, patient: patient, starts_at: starts_at, ends_at: ends_at)
    end
  rescue ActiveRecord::StatementInvalid => e
    raise unless e.cause.is_a?(PG::ExclusionViolation)

    raise SlotUnavailableError, "Provider is already booked for that time"
  end

  def cancel!(reason: nil)
    update!(status: :cancelled, cancellation_reason: reason)
  end

  private

  def ends_after_starts
    return if starts_at.blank? || ends_at.blank?

    errors.add(:ends_at, "must be after the start time") if ends_at <= starts_at
  end

  def starts_in_future
    errors.add(:starts_at, "must be in the future") if starts_at.present? && starts_at < Time.current
  end

  def schedule_reminder
    return unless scheduled?

    reminder_time = starts_at - 24.hours
    AppointmentReminderJob.set(wait_until: [ reminder_time, Time.current ].max).perform_later(id)
  end
end
