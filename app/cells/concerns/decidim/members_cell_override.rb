# frozen_string_literal: true

module Decidim
  module MembersCellOverride
    extend ActiveSupport::Concern

    included do
      # Calculate arrays for each user type
      def individual_members
        @individual_members ||= memberships.select { |m| m.user.extended_data["user_type"] == "individual" }
      end

      def pyme_members
        @pyme_members ||= memberships.select { |m| m.user.extended_data["user_type"] == "pyme" }
      end

      def local_entity_members
        @local_entity_members ||= memberships.select { |m| m.user.extended_data["user_type"] == "local_entity" }
      end
    end
  end
end
