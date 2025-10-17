# frozen_string_literal: true

module Decidim
  module UserGroupMembershipOverride
    extend ActiveSupport::Concern

    included do
      # When membership role changes to "member" (accepted)
      after_update :sync_energy_community_authorization_on_acceptance, if: :saved_change_to_role?

      # When membership is destroyed (user leaves or is removed)
      after_destroy :sync_energy_community_authorization_on_removal

      private

      def sync_energy_community_authorization_on_acceptance
        return unless role == "member"

        EnergyCommunityAutoVerificationJob.perform_later(decidim_user_id)
      end

      def sync_energy_community_authorization_on_removal
        return unless decidim_user_id

        EnergyCommunityAutoVerificationJob.perform_later(decidim_user_id)
      end
    end
  end
end
