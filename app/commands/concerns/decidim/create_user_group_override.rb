# frozen_string_literal: true

module Decidim
  module CreateUserGroupOverride
    extend ActiveSupport::Concern

    included do
      private

      def create_user_group
        @user_group = UserGroup.create!(
          email: form.email,
          name: form.name,
          nickname: form.nickname,
          organization: form.current_organization,
          about: form.about,
          avatar: form.avatar,
          address: form.address,
          latitude: form.latitude,
          longitude: form.longitude,
          extended_data: {
            phone: form.phone,
            document_number: form.document_number
          }
        )
      end
    end
  end
end
