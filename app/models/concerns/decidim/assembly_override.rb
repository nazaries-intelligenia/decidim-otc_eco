# frozen_string_literal: true

module Decidim
  module AssemblyOverride
    extend ActiveSupport::Concern

    included do
      belongs_to :user_group,
                 foreign_key: "decidim_user_group_id",
                 class_name: "Decidim::UserGroup",
                 optional: true
    end
  end
end
