# frozen_string_literal: true

module Decidim
  module Devise
    module RegistrationsControllerOverride
      extend ActiveSupport::Concern

      included do
        protected

        def configure_permitted_parameters
          devise_parameter_sanitizer.permit(:sign_up, keys: [:name, :tos_agreement, :user_type])
        end
      end
    end
  end
end
