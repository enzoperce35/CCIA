Rails.application.routes.draw do
  devise_for :users
  
  root 'home#index'

  post '/coins/trade', to: 'coins#trade', as: 'trade'
  get '/coins/show_trade', to: 'coins#show_trade', as: 'show_trade'

  resources :coins, only: [:new, :create, :show, :destroy]

  
end
