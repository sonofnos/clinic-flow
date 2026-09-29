module Api
  module V1
    class ProvidersController < ApplicationController
      def index
        providers = Provider.includes(:user).order(:id)
        render json: providers.map { |p| provider_json(p) }
      end

      def show
        provider = Provider.includes(:user).find(params[:id])
        render json: provider_json(provider)
      end

      private

      def provider_json(provider)
        {
          id: provider.id,
          name: provider.user.name,
          specialty: provider.specialty,
          bio: provider.bio
        }
      end
    end
  end
end
