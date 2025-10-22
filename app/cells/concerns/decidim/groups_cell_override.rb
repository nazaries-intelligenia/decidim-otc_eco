# frozen_string_literal: true

module Decidim
  module GroupsCellOverride
    extend ActiveSupport::Concern

    included do
      def geocoded_user_groups
        @geocoded_user_groups ||= Decidim::UserGroup.all.select(&:geocoded_and_valid?)
      end

      def display_map?
        Decidim::Map.available?(:geocoding, :dynamic) && geocoded_user_groups.any?
      end
    end
  end
end
