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
            ec_agents: form.ec_agents,
            installed_power: form.installed_power,
            legal_form: form.legal_form,
            creation_date: form.creation_date,
            action_types: form.action_types,
            financial_support: form.financial_support,
            project_website: form.project_website,
            contact_person: form.contact_person,
            phone: form.phone,
            privacy_policy_accepted: form.privacy_policy_accepted,
            privacy_policy_accepted_at: form.privacy_policy_accepted ? Time.current : nil
          }
        }
      end
    end
  end
end
