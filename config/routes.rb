# frozen_string_literal: true

require "sidekiq/web"

Rails.application.routes.draw do
  mount LetterOpenerWeb::Engine, at: "/letter_opener" if Rails.env.development?

  Decidim::Core::Engine.routes.draw do
    scope "/profiles/:nickname", format: false, constraints: { nickname: %r{[^/]+} } do
      get "information", to: "profiles#information", as: "profile_information"
      get "contact", to: "profiles#contact", as: "profile_contact"
    end
  end

  mount Decidim::Core::Engine => "/"
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  # root "articles#index"

  if Rails.env.production?
    authenticate :user, ->(u) { u.admin? } do
      mount Sidekiq::Web => "/sidekiq"
    end
  end
end
