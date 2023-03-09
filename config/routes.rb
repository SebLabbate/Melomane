Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  # root "articles#index"
  devise_for :users
  root to: "pages#home"
  get "/dashboard", to: "pages#dashboard"
  get "/dashboard/new", to: "gigs#new"
  post "/gigs", to: "gigs#create"
  get "/user_gigs/past_gigs", to: "past_gigs#index"

  resources :gigs, only: %i[index show] do
    resources :user_gigs, only: :create
  end
  resources :user_gigs, only: %i[index show]
end
