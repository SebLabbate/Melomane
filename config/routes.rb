Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  # root "articles#index"
  devise_for :users
  root to: "pages#home"
  get "/dashboard", to: "pages#dashboard"
  get "/dashboard/new", to: "gigs#new"
  post "/gigs", to: "gigs#create"
  # get "/attend", to: "user_gigs#attend", as: "user_gig_attend"
  post "user_gigs/:id/toggle", to: "user_gigs#toggle"

  # resources :gigs, only: %i[index show] do
  resources :gigs do
    resources :user_gigs, only: :create
  end

  resources :user_gigs do
    collection do
      get :past_gigs
      get :upcoming_gigs
    end
    # resources :comments, only: %i[new create]
    resources :comments do
      delete :destroy_attachment, on: :member
    end
  end

  # only: %i[index show update]
end
