# frozen_string_literal: true

module Decidim
  module UserGroupMembershipOverride
    extend ActiveSupport::Concern

    included do
      after_save :sync_admin_role_with_assembly, if: :saved_change_to_role?

      private

      def sync_admin_role_with_assembly
        return unless user_group.assembly.present?

        if role == "admin"
          grant_assembly_admin_access
        else
          revoke_assembly_admin_access
        end
      end

      def grant_assembly_admin_access
        Decidim::AssemblyUserRole.find_or_create_by!(
          user: user,
          assembly: user_group.assembly,
          role: "admin"
        )
      end

      def revoke_assembly_admin_access
        Decidim::AssemblyUserRole.find_by(
          user: user,
          assembly: user_group.assembly,
          role: "admin"
        )&.destroy
      end
    end
  end
end
