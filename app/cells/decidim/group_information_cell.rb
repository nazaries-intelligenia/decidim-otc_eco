# frozen_string_literal: true

module Decidim
  class GroupInformationCell < Decidim::ViewModel
    def show
      render :show
    end

    def user_group
      model
    end

    def about
      decidim_html_escape translated_attribute(user_group.about).to_s
    end
  end
end
