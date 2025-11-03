# frozen_string_literal: true

module Decidim
  module ProfileCellOverride
    extend ActiveSupport::Concern

    included do
      def user_type_label
        return nil if user_group? || profile_holder.extended_data.blank?

        type = profile_holder.extended_data["user_type"]
        return nil if type.blank?

        I18n.t("user_types.#{type}", default: type)
      end
    end
  end
end
