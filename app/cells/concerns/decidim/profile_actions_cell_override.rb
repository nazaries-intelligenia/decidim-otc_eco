# frozen_string_literal: true

module Decidim
  module ProfileActionsCellOverride
    extend ActiveSupport::Concern

    included do
      private

      # Display create user group button only for admins
      def actions_keys
        @actions_keys ||= [].tap do |keys|
          keys << :edit_profile if own_profile?
          keys << :create_user_group if own_profile? && user_groups_enabled? && current_user&.admin?
          keys << message_key if can_contact_user?
          keys << :join_user_group if can_join_user_group?
          keys << :leave_user_group if can_leave_group?
        end
      end
    end
  end
end
