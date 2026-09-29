class AppointmentMailer < ApplicationMailer
  def reminder(appointment)
    @appointment = appointment
    @patient = appointment.patient
    @provider = appointment.provider

    mail(to: @patient.email, subject: "Reminder: your appointment tomorrow") if @patient.email.present?
  end
end
