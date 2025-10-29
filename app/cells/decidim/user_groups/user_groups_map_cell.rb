# frozen_string_literal: true

module Decidim
  module UserGroups
    # Custom map cell for user groups that handles routing differently
    # since UserGroups are not component resources
    class UserGroupsMapCell < Decidim::MapCell
      include Decidim::Core::Engine.routes.url_helpers

      private

      def data_for_map
        data = model.is_a?(Array) ? model : [model]
        data.select(&:geocoded_and_valid?).map do |user_group|
          user_group.slice(:latitude, :longitude, :address)
                    .merge(
                      title: user_group.name,
                      link: profile_path(user_group.nickname),
                      items: cell(options[:metadata_card], user_group).send(:items_for_map).to_json
                    )
        end
      end
    end
  end
end
