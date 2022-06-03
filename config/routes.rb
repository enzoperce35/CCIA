Rails.application.routes.draw do
  devise_for :users
  
  root 'home#index'

  post 'coins/make_trade', to: 'coins#make_trade'
  post 'coins/edit_user_coin'
  post 'home/observe'
  get 'coins/holdings'
  post 'coins/gain_reset'
  post 'coins/major_reset'

  resources :coins, only: [:new, :create, :show, :destroy, :update]
end
