# frozen_string_literal: true

module Decidim
  module ProfilesControllerOverride
    extend ActiveSupport::Concern

    included do
      before_action :check_missing_credentials, only: [:members, :group_members, :group_admins, :group_invites]

      private

      def check_missing_credentials
        ensure_profile_holder_is_a_group
        return unless can_manage_user_group_credentials?
        return if profile_holder.cif.present? && profile_holder.datadis_password.present?

        flash.now[:warning] = I18n.t("missing_credentials_warning", scope: "decidim.user_group_credentials")
      end

      def can_manage_user_group_credentials?
        return false unless current_user

        membership = Decidim::UserGroupMembership.find_by(
          decidim_user_id: current_user.id,
          decidim_user_group_id: profile_holder.id
        )
        membership&.role&.in?(%w(admin))
      end
    end
  end
end
