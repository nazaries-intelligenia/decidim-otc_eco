# frozen_string_literal: true

module Decidim
  module ProfileCellOverride
    extend ActiveSupport::Concern

    included do
      remove_const(:TABS_ITEMS) if const_defined?(:TABS_ITEMS)

      const_set(:TABS_ITEMS, {
        activity: { icon: "bubble-chart-line", path: :profile_activity_path },
        badges: { icon: "award-line", path: :profile_badges_path },
        following: { icon: "eye-2-line", path: :profile_following_path },
        followers: { icon: "group-line", path: :profile_followers_path },
        groups: { icon: "team-line", path: :profile_groups_path },
        members: { icon: "contacts-line", path: :profile_members_path },
        information: { icon: "information-line", path: :profile_information_path },
        contact: { icon: "phone-line", path: :profile_contact_path },
        conversations: { icon: "question-answer-line", path: :profile_conversations_path }
      }.freeze)

      private

      def group_tabs
        items = [:information, :contact, :members]
        items.map { |key| tab_item(key) }
      end
    end
  end
end
