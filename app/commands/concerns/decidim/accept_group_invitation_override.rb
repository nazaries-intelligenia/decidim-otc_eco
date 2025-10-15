# frozen_string_literal: true

module Decidim
  module AcceptGroupInvitationOverride
    extend ActiveSupport::Concern

    included do

      def call
        return broadcast(:invalid) if membership.blank?

        transaction do
          accept_invitation
          add_to_assembly_private_users
        end

        broadcast(:ok)
      end

      private

      def add_to_assembly_private_users
        return unless user_group.assembly.present?

        Decidim::ParticipatorySpacePrivateUser.find_or_create_by!(
          user: user,
          privatable_to: user_group.assembly,
          published: true
        )
      end
    end
  end
end
