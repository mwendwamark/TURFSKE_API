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
    post "/auth/confirmation", to: "auth/confirmations#create"
    post "/auth/confirmation/resend", to: "auth/confirmations#resend"
    get "/auth/confirmation", to: "auth/confirmations#show", as: :user_confirmation
  end

  namespace :managers do
    resources :turf_venues do
      collection do
        post :complete_create
      end
      member do
        post   :upload_images
        delete "delete_image/:image_id", action: :delete_image, as: :delete_image
      end

      resource  :amenity,      only: [:show, :create]
      resources :turfs do
        resources :availability,
          controller: "turf_availabilities",
          only: [:index, :create]
      end
    end
  end

  namespace :players do
    resources :turf_venues, only: [:index, :show]
  end

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  get "up" => "rails/health#show", as: :rails_health_check
end
