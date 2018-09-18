Rails.application.routes.draw do
  require 'sidekiq/web'
  mount Sidekiq::Web => '/sidekiq'
  root to: 'visitors#index'
  devise_for :users
  resources :users
  resources :publications do
    get :autocomplete_publication_root_url, on: :collection
  end
end
