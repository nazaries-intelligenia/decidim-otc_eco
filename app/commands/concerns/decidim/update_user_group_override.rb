# frozen_string_literal: true

module Decidim
  module UpdateUserGroupOverride
    extend ActiveSupport::Concern

    included do
      private

      def attributes
        {
          email: form.email,
          name: form.name,
          nickname: form.nickname,
          about: form.about,
          avatar: form.avatar,
          address: form.address,
          latitude: form.latitude,
          longitude: form.longitude,
          extended_data: {
            phone: form.phone,
            document_number: form.document_number
          }
        }
      end
    end
  end
end
