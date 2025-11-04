# frozen_string_literal: true

module Decidim
  class GroupContactCell < Decidim::ViewModel
    def show
      render :show
    end

    def user_group
      model
    end

    delegate :email, to: :user_group

    delegate :phone, to: :user_group

    def contact_person
      user_group.extended_data["contact_person"]
    end
  end
end
