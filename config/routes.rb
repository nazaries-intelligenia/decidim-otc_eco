# frozen_string_literal: true

Rails.application.routes.draw do
  mount LetterOpenerWeb::Engine, at: "/letter_opener" if Rails.env.development?

  mount Decidim::Core::Engine => "/"

  # User group credentials routes
  Decidim::Core::Engine.routes.draw do
    scope "/profiles/:nickname" do
      get "credentials/edit", to: "user_group_credentials#edit", as: "edit_user_group_credentials"
      patch "credentials", to: "user_group_credentials#update", as: "user_group_credentials"
    end
  end
end
