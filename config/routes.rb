Rails.application.routes.draw do
  # Model Context Protocol - POST only per MCP spec
  post "/mcp", to: "mcp#handle"

  # RPG-style interfaces (main experience)
  resources :recipes, only: %i[index show]
  resources :meal_plans, only: %i[index show new create destroy]
  resources :pantry_items, only: %i[index new create edit update destroy]

  # Traditional "My Stuff" views
  namespace :my_stuff do
    resources :recipes, only: %i[index show destroy]
  end

  resources :users do
      put :toggle_activate, on: :member
  end
  resource :session
  resources :passwords, param: :token

  # OAuth routes
  get "/auth/:provider/callback", to: "omniauth_callbacks#google_oauth2"
  post "/auth/:provider/callback", to: "omniauth_callbacks#google_oauth2"
  get "/auth/failure", to: "omniauth_callbacks#failure"
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Defines the root path route ("/")
  root "main#index"
end
