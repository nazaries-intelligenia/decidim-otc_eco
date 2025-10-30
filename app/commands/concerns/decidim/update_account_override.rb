# frozen_string_literal: true

module Decidim
  module UpdateAccountOverride
    extend ActiveSupport::Concern

    included do
      private

      def update_personal_data
        current_user.locale = @form.locale
        current_user.name = @form.name
        current_user.nickname = @form.nickname
        current_user.email = @form.email
        current_user.personal_url = @form.personal_url
        current_user.about = @form.about
        current_user.extended_data = (current_user.extended_data || {}).merge(
          "user_type" => @form.user_type
        )
      end
    end
  end
end
