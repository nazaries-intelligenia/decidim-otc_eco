# frozen_string_literal: true

module Decidim
  module AcceptUserGroupJoinRequestOverride
    extend ActiveSupport::Concern

    included do

      def call
        return broadcast(:invalid) if membership.role.to_s != "requested"

        transaction do
          accept_membership
          add_to_assembly_private_users
          send_notification
        end

        broadcast(:ok, @user_group)
      end

      private

      def add_to_assembly_private_users
        return unless membership.user_group.assembly.present?

        Decidim::ParticipatorySpacePrivateUser.find_or_create_by!(
          user: membership.user,
          privatable_to: membership.user_group.assembly,
          published: true
        )
      end
    end
  end
end
