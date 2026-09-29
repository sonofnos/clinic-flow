module Api
  module V1
    class AppointmentsController < ApplicationController
      before_action :authorize_staff!, only: [ :create, :cancel ]

      def index
        scope = Appointment.includes(:provider, :patient, provider: :user)
        scope = scope.where(provider_id: params[:provider_id]) if params[:provider_id].present?
        scope = scope.where(patient_id: params[:patient_id]) if params[:patient_id].present?
        render json: scope.order(:starts_at).map { |a| appointment_json(a) }
      end

      def create
        provider = Provider.find(appointment_params[:provider_id])
        patient = Patient.find(appointment_params[:patient_id])

        appointment = Appointment.book!(
          provider: provider,
          patient: patient,
          starts_at: appointment_params[:starts_at],
          ends_at: appointment_params[:ends_at]
        )

        render json: appointment_json(appointment), status: :created
      end

      def cancel
        appointment = Appointment.find(params[:id])
        appointment.cancel!(reason: params[:reason])
        render json: appointment_json(appointment)
      end

      private

      def appointment_params
        params.permit(:provider_id, :patient_id, :starts_at, :ends_at)
      end

      def appointment_json(appointment)
        {
          id: appointment.id,
          status: appointment.status,
          starts_at: appointment.starts_at,
          ends_at: appointment.ends_at,
          provider: { id: appointment.provider.id, name: appointment.provider.user.name },
          patient: { id: appointment.patient.id, name: appointment.patient.name }
        }
      end

      def authorize_staff!
        authorize_roles!(:admin, :staff)
      end
    end
  end
end
