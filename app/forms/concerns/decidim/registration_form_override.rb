# frozen_string_literal: true

module Decidim
  module RegistrationFormOverride
    extend ActiveSupport::Concern

    USER_TYPES = %w[individual pyme local_entity].freeze

    included do
      attribute :user_type, String

      validates :user_type, presence: true, inclusion: { in: USER_TYPES }
    end
  end
end
