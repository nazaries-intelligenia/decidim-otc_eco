# frozen_string_literal: true

module Decidim
  module RemoveUserFromGroupOverride
    extend ActiveSupport::Concern

    included do
      def call
        return broadcast(:invalid) if membership.blank?
        return broadcast(:invalid) if membership.user_group != user_group

        transaction do
          remove_membership
          remove_from_assembly_private_users
          send_notification
        end

        broadcast(:ok)
      end

      private

      def remove_from_assembly_private_users
        return if user_group.assembly.blank?

        Decidim::ParticipatorySpacePrivateUser
          .find_by(user: membership.user, privatable_to: user_group.assembly)
          &.destroy
      end
    end
  end
end
