# frozen_string_literal: true

module Decidim
  module ProfileActionsCellOverride
    extend ActiveSupport::Concern

    included do
      # Extend ACTIONS_ITEMS with our edit_user_group_credentials action
      EXTENDED_ACTIONS_ITEMS = Decidim::ProfileActionsCell::ACTIONS_ITEMS.merge(
        edit_user_group_credentials: { icon: "tools-line", path: :edit_user_group_credentials_path }
      ).freeze

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

      # Add credentials action to group editor dropdown
      def group_editor_actions_keys
        @group_editor_actions_keys ||= if can_edit_user_group_profile?
                                        [
                                          :edit_user_group,
                                          :manage_user_group_users,
                                          :manage_user_group_admins,
                                          :invite_user,
                                          :edit_user_group_credentials
                                        ].tap do |keys|
                                          keys.prepend(:resend_email_confirmation_instructions) if user_group_email_to_be_confirmed?
                                          keys << :join_user_group if can_join_user_group?
                                          keys << :leave_user_group if can_leave_group?
                                        end
                                      else
                                        []
                                      end
      end

      def action_item(key, translations_scope: "decidim.profiles.user.actions")
        return if EXTENDED_ACTIONS_ITEMS[key].blank?

        values = EXTENDED_ACTIONS_ITEMS[key].dup
        values[:options] = values.delete(:options) || {}
        return values if values.has_key?(:cell)

        values[:path] = send(values[:path], profile_holder.nickname) if values[:path].present?
        values[:text] = t(key, scope: translations_scope)
        values
      end
    end
  end
end
