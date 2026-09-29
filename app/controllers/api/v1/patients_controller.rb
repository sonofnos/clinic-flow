module Api
  module V1
    class PatientsController < ApplicationController
      before_action :authorize_staff!, except: [ :show ]

      def index
        render json: Patient.order(:name).map { |p| patient_json(p) }
      end

      def show
        render json: patient_json(Patient.find(params[:id]))
      end

      def create
        patient = Patient.create!(patient_params)
        render json: patient_json(patient), status: :created
      end

      def update
        patient = Patient.find(params[:id])
        patient.update!(patient_params)
        render json: patient_json(patient)
      end

      private

      def patient_params
        params.permit(:name, :date_of_birth, :phone, :email, :notes)
      end

      def patient_json(patient)
        {
          id: patient.id,
          name: patient.name,
          date_of_birth: patient.date_of_birth,
          phone: patient.phone,
          email: patient.email,
          notes: patient.notes
        }
      end

      def authorize_staff!
        authorize_roles!(:admin, :staff)
      end
    end
  end
end
