Rails.application.routes.draw do
  get "up" => "rails/health#show", as: :rails_health_check

  patch "locale", to: "locales#update", as: :locale

  get "login", to: "sessions#new"
  post "login", to: "sessions#create"
  delete "logout", to: "sessions#destroy"

  root "products#index"

  resources :products, only: [ :index ]

  resource :cart, only: [ :show ] do
    post :add
    patch :update
    delete :clear
  end

  resources :orders, only: %i[index show create destroy]

  resource :account, only: %i[edit update], controller: "account"

  namespace :admin do
    root "dashboard#index"
    resources :products
    resources :franchises, except: :destroy do
      member do
        post :reset_password
      end
    end
    resources :users, only: %i[index new create] do
      member do
        post :reset_password
      end
    end
    resources :orders, only: %i[index show update]
  end

  match "/404", to: "errors#not_found", via: :all
  match "/422", to: "errors#unprocessable_entity", via: :all
  match "/500", to: "errors#internal_server_error", via: :all
end
