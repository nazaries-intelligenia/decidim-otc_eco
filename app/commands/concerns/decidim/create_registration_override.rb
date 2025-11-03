# frozen_string_literal: true

module Decidim
  module CreateRegistrationOverride
    extend ActiveSupport::Concern

    included do
      private

      def create_user
        @user = User.create!(
          email: form.email,
          name: form.name,
          nickname: form.nickname,
          password: form.password,
          password_updated_at: Time.current,
          organization: form.current_organization,
          tos_agreement: form.tos_agreement,
          newsletter_notifications_at: form.newsletter_at,
          accepted_tos_version: form.current_organization.tos_version,
          locale: form.current_locale,
          extended_data: {
            user_type: form.user_type
          }
        )
      end
    end
  end
end
