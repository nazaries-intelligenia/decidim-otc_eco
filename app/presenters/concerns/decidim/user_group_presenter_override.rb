# frozen_string_literal: true

module Decidim
  module UserGroupPresenterOverride
    extend ActiveSupport::Concern

    included do
      # Title for the user group (used in maps and cards)
      def title
        __getobj__.name
      end
    end
  end
end
