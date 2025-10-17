# frozen_string_literal: true

module Decidim
  module UserGroupFormOverride
    extend ActiveSupport::Concern

    included do
      validates :name, format: { with: Decidim::UserBaseEntity::REGEXP_NAME }
      validates :nickname, format: { with: Decidim::UserBaseEntity::REGEXP_NICKNAME }
    end
  end
end
