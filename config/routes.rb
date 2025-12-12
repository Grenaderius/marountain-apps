Rails.application.routes.draw do
  # JWT Auth
  post "/login", to: "auth#login"
  get "/apps/my", to: "apps#my", defaults: { format: :json }

  resources :apps
  resources :users, only: [:index, :show, :create]
  resources :comments, only: [:index, :create, :update, :destroy]

  post "/upload", to: "uploads#create"

  # payment
  post "/payments/create_checkout_session", to: "payments#create_checkout_session"
  post "/stripe/webhook", to: "stripe#webhook"
  get "/purchases/my", to: "purchases#my"
  post "payments/success", to: "payments#success"

  resources :purchases, only: [] do
    collection do
      get :my
    end
  end

  # Google Drive API
  post "/drive/upload", to: "google_drive#upload"
  delete "/drive/files/:id", to: "google_drive#delete"
  get "/drive/files", to: "google_drive#list"
  get "/drive/files/:id/download", to: "google_drive#download"

  namespace :api do
    namespace :v1 do
      get "hello", to: "hello#index"
      post "gemini-compatibility", to: "gemini#compatibility"
    end
  end

  root "home#index"
  get "*path", to: "home#index", constraints: ->(req) { !req.xhr? && req.format.html? }
end
