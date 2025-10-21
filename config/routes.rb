Rails.application.routes.draw do
resources :apps
  resources :users, only: [:index, :show, :create]
  resources :comments, only: [:index, :create]

  namespace :api do
    namespace :v1 do
      get "hello", to: "hello#index"
    end
  end

  post "/login", to: "sessions#create"

  root "home#index"

  # щоб React міг обробляти свої маршрути
  get "*path", to: "home#index", constraints: ->(req) { !req.xhr? && req.format.html? }
end
