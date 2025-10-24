# frozen_string_literal: true

module Decidim
  module UserGroupOverride
    extend ActiveSupport::Concern

    included do
      include Decidim::RecordEncryptor

      encrypt_attribute :datadis_password, type: :string

      has_one :assembly, class_name: "Decidim::Assembly", foreign_key: :decidim_user_group_id, dependent: :destroy

      validates :cif, format: { with: /\A[A-Z]\d{8}\z/ }, allow_blank: true
    end
  end
end
