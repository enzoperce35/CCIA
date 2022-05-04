class HomeController < ApplicationController
  before_action :authenticate_user!
  
  def index
    @observe = params[:observe]

    coins = Coin.pluck('coin_id').join(', ')
    
    @coins = helpers.insert_extra_values_from( coins )
  end
end
