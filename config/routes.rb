Rails.application.routes.draw do
  get "up" => "rails/health#show", as: :rails_health_check

  patch "locale", to: "locales#update", as: :locale

  get "login", to: "sessions#new"
  post "login", to: "sessions#create"
  delete "logout", to: "sessions#destroy"

  root "products#index"

  resources :products, only: [:index]

  resource :cart, only: [:show] do
    post :add
    patch :update
    delete :clear
  end

  resources :orders, only: %i[index show create destroy]

  namespace :admin do
    root "dashboard#index"
    resources :products
    resources :franchises, only: %i[index show edit update]
    resources :orders, only: %i[index show update]
  end
end
