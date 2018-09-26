Rails.application.routes.draw do
  require 'sidekiq/web'
  mount Sidekiq::Web => '/sidekiq'
  root to: 'visitors#index'
  devise_for :users
  resources :users
  resources :publications do
    get :autocomplete_publication_root_url, on: :collection
  end
  
  get '/remove_user_publication', to: 'users#remove_publication_from_user', as: "remove_user_publication"
end
