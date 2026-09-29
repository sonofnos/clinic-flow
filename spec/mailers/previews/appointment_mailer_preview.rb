# Preview all emails at http://localhost:3000/rails/mailers/appointment_mailer_mailer
class AppointmentMailerPreview < ActionMailer::Preview
  # Preview this email at http://localhost:3000/rails/mailers/appointment_mailer_mailer/reminder
  def reminder
    AppointmentMailer.reminder(Appointment.first || FactoryBot.create(:appointment))
  end
end
