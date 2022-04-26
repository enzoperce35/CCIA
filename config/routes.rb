Rails.application.routes.draw do
  devise_for :users
  
  root 'home#index'

  resources :coins, only: [:new, :create, :show, :destroy, :update]
end
