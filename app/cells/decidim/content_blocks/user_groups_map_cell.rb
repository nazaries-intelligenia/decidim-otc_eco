# frozen_string_literal: true

module Decidim
  module ContentBlocks
    class UserGroupsMapCell < Decidim::MapCell
      include Decidim::Core::Engine.routes.url_helpers

      def geocoded_user_groups
        @geocoded_user_groups ||= Decidim::UserGroup.where(decidim_organization_id: current_organization.id).select(&:geocoded_and_valid?)
      end

      def display_map?
        Decidim::Map.available?(:geocoding, :dynamic) && geocoded_user_groups.any?
      end
    end
  end
end
