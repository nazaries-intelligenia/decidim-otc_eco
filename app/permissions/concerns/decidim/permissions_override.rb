# frozen_string_literal: true

module Decidim
  module PermissionsOverride
    extend ActiveSupport::Concern

    included do
      private

      def user_group_action?
        return false unless permission_action.subject == :user_group

        # Only allow admins to create user groups
        if permission_action.action == :create
          is_admin = user&.admin? || user.organization&.admins&.include?(user)
          return toggle_allow(is_admin)
        end

        # Allow any authenticated user to join groups
        return allow! if permission_action.action == :join

        user_group = context.fetch(:user_group)

        if permission_action.action == :leave
          user_can_leave_group = Decidim::UserGroupMembership.where(user:, user_group:).any?
          return toggle_allow(user_can_leave_group)
        end

        user_manages_group = Decidim::UserGroups::ManageableUserGroups.for(user).include?(user_group)
        toggle_allow(user_manages_group) if permission_action.action == :manage
      end
    end
  end
end
