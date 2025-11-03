# frozen_string_literal: true

module Decidim
  module AccountControllerOverride
    extend ActiveSupport::Concern

    included do
      def show
        enforce_permission_to(:show, :user, current_user:)
        @account = form(AccountForm).from_model(current_user)
        @account.password = nil
        @account.user_type = current_user.extended_data&.dig("user_type")
      end
    end
  end
end
