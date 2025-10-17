# frozen_string_literal: true

module Decidim
  module Verifications
    # Authorization handler for Energy Community Members
    #
    # This handler verifies that a user belongs to at least one energy community (user group).
    # It's automatically managed by the system when users join or leave groups.
    #
    class EnergyCommunityMember < Decidim::AuthorizationHandler
      validate :user_in_group

      # Custom metadata that includes the list of user group IDs
      def metadata
        super.merge(
          energy_community_ids: user_group_ids
        )
      end

      protected

      def user_group_ids
        @user_group_ids ||= user&.user_groups&.pluck(:id) || []
      end

      def user_in_group
        errors.add(:user, I18n.t("decidim.errors.not_in_energy_community")) if user_group_ids.blank?
      end
    end
  end
end
