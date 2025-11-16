Rails.application.routes.draw do
  resources :apps
  resources :users, only: [:index, :show, :create]
  resources :comments, only: [:index, :create]

  post "/login", to: "sessions#create"
  post "/upload", to: "uploads#create"

  namespace :api do
    namespace :v1 do
      get "hello", to: "hello#index"
      post "gemini-compatibility", to: "gemini#compatibility"
    end
  end

  root "home#index"

  # React fallback (must be LAST!)
  get "*path", to: "home#index", constraints: ->(req) { !req.xhr? && req.format.html? }
end
