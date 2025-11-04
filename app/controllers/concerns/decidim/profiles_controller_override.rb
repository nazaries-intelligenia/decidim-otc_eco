# frozen_string_literal: true

module Decidim
  module ProfilesControllerOverride
    extend ActiveSupport::Concern
    def show
      return redirect_to profile_information_path(nickname: params[:nickname].downcase) if profile_holder.is_a?(Decidim::UserGroup)

      redirect_to profile_activity_path(nickname: params[:nickname].downcase)
    end

    def information
      enforce_user_groups_enabled
      ensure_profile_holder_is_a_group

      @content_cell = "decidim/group_information"
      @title_key = "information"
      render :show
    end

    def contact
      enforce_user_groups_enabled
      ensure_profile_holder_is_a_group

      @content_cell = "decidim/group_contact"
      @title_key = "contact"
      render :show
    end
  end
end
