# frozen_string_literal: true

module Decidim
  module UserGroupMembershipOverride
    extend ActiveSupport::Concern

    included do
      after_save :sync_admin_role_with_assembly, if: :saved_change_to_role?
      after_destroy :revoke_assembly_admin_access_on_destroy

      private

      def sync_admin_role_with_assembly
        assembly = find_assembly
        return if assembly.blank?

        if role == "admin"
          grant_assembly_admin_access(assembly)
        else
          revoke_assembly_admin_access(assembly)
        end
      end

      def revoke_assembly_admin_access_on_destroy
        assembly = find_assembly
        return if assembly.blank?

        revoke_assembly_admin_access(assembly)
      end

      def find_assembly
        Decidim::Assembly.find_by(user_group: user_group)
      end

      def grant_assembly_admin_access(assembly)
        Decidim::AssemblyUserRole.find_or_create_by!(
          user: user,
          assembly: assembly,
          role: "admin"
        )
      end

      def revoke_assembly_admin_access(assembly)
        Decidim::AssemblyUserRole.find_by(
          user: user,
          assembly: assembly,
          role: "admin"
        )&.destroy
      end
    end
  end
end
