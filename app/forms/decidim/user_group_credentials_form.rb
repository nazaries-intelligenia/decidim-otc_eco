# frozen_string_literal: true

module Decidim
  # A form object used to update CIF and password for a user group
  class UserGroupCredentialsForm < Form
    mimic :user_group

    attribute :cif, String
    attribute :datadis_password, String

    validates :cif, presence: true, format: { with: /\A[A-Z]\d{8}\z/ }
    validates :datadis_password, presence: true
  end
end
