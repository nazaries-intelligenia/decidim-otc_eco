# frozen_string_literal: true

module Decidim
  module UserGroupOverride
    extend ActiveSupport::Concern

    included do
      has_one :assembly, class_name: "Decidim::Assembly", foreign_key: :decidim_user_group_id, dependent: :destroy
    end
  end
end
