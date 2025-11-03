# frozen_string_literal: true

module Decidim
  module LeaveUserGroupOverride
    extend ActiveSupport::Concern

    included do
      private

      def leave_user_group
        transaction do
          Decidim::UserGroupMembership.find_by!(user:, user_group:).destroy!
          remove_from_assembly_private_users
        end
      end

      def remove_from_assembly_private_users
        assembly = Decidim::Assembly.find_by(user_group: user_group)
        return if assembly.blank?

        Decidim::ParticipatorySpacePrivateUser
          .find_by(user: user, privatable_to: assembly)
          &.destroy
      end
    end
  end
end
