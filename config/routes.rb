Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  # root "articles#index"
  devise_for :users
  root to: "pages#home"
  get "/dashboard", to: "pages#dashboard"

  resources :gigs, only: :index do
    resources :user_gigs, only: :create
  end
  resources :user_gigs, only: %i[index show]
end
