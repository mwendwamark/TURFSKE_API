Rails.application.routes.draw do
  devise_for :users, skip: :all

  # Test endpoint for JWT authentication
  get "/test_auth", to: "test#index"

  devise_scope :user do
    # Players
    post "/players/signup", to: "players/registrations#create"
    post "/players/login", to: "players/sessions#create"
    delete "/players/logout", to: "players/sessions#destroy"
    post "/players/password", to: "players/passwords#create"
    put "/players/password", to: "players/passwords#update"

    # Managers
    post "/managers/signup", to: "managers/registrations#create"
    post "/managers/login", to: "managers/sessions#create"
    delete "/managers/logout", to: "managers/sessions#destroy"
    post "/managers/password", to: "managers/passwords#create"
    put "/managers/password", to: "managers/passwords#update"

    # Email confirmation
    get "/auth/confirmation", to: "auth/confirmations#show", as: :user_confirmation
  end

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  get "up" => "rails/health#show", as: :rails_health_check
end
