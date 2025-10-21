# frozen_string_literal: true

module Decidim
  module UserGroups
    # This cell renders metadata for an instance of a UserGroup for map display
    class UserGroupCardMetadataCell < Decidim::CardMetadataCell
      alias user_group model

      delegate :nickname, to: :user_group

      def initialize(*)
        super

        @items.prepend(*user_group_items)
      end

      private

      def user_group_items
        [nickname_item, members_count_item]
      end

      def items_for_map
        [nickname_item, members_count_item].compact_blank.map do |item|
          {
            text: item[:text],
            icon: icon(item[:icon]).html_safe
          }
        end
      end

      def nickname_item
        return unless nickname.present?

        {
          text: "@#{nickname}",
          icon: "account-circle-line"
        }
      end

      def members_count_item
        count = user_group.memberships.where.not(role: 'requested').count
        return if count.zero?

        {
          text: t("decidim.groups.members_count", count: count),
          icon: "group-line"
        }
      end
    end
  end
end
