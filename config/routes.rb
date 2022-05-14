Rails.application.routes.draw do
  devise_for :users
  
  root 'home#index'

  get 'coins/trade_coins', as: 'trade'
  post 'coins/make_trade', to: 'coins#make_trade'
  post 'coins/edit_user_coin'
  post 'home/observe'
  get 'coins/holdings'
  post 'coins/gain_reset'

  resources :coins, only: [:new, :create, :show, :destroy, :update]
end
