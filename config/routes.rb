Rails.application.routes.draw do
  devise_for :users
  
  root 'coins#index'

  get 'home/index', as: 'home'
  get 'coins/trade_coin', as: 'trade'
  post 'coins/make_trade', to: 'coins#make_trade'
  post 'coins/gain_reset'
  post 'coins/observe'

  resources :coins
end
