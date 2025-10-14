# frozen_string_literal: true

module Decidim
  module UserGroupOverride
    extend ActiveSupport::Concern

    included do
      geocoded_by :address
    end
  end
end
