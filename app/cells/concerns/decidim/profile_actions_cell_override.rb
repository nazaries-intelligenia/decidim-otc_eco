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

      # Override action_item to fix translation loading for leave_user_group
      def action_item(key, translations_scope: "decidim.profiles.user.actions")
        return if self.class::ACTIONS_ITEMS[key].blank?

        values = self.class::ACTIONS_ITEMS[key].dup
        values[:options] = values.delete(:options) || {}
        return values if values.has_key?(:cell)

        # Fix: Load the confirm translation dynamically for leave_user_group
        if key == :leave_user_group
          values[:options][:method] = :delete
          values[:options][:data] = { confirm: I18n.t("decidim.groups.actions.are_you_sure") }
        end

        values[:path] = send(values[:path], profile_holder.nickname) if values[:path].present?
        values[:text] = t(key, scope: translations_scope)
        values
      end
    end
  end
end
