class AppointmentReminderJob < ApplicationJob
  queue_as :default

  def perform(appointment_id)
    appointment = Appointment.find_by(id: appointment_id)
    return if appointment.nil? || !appointment.scheduled?

    AppointmentMailer.reminder(appointment).deliver_later
  end
end
