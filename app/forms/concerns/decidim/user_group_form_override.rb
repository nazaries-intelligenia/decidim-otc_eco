# frozen_string_literal: true

module Decidim
  module UserGroupFormOverride
    extend ActiveSupport::Concern

    included do
      validates :name, format: { with: Decidim::UserBaseEntity::REGEXP_NAME }

      # Since we create the assembly's slug from the nickname, we need to validate it with the same format as the slugs.
      validates :nickname, format: { with: Decidim::Assembly.slug_format }
    end
  end
end
