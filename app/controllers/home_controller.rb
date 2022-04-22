class HomeController < ApplicationController
  before_action :authenticate_user!
  
  def index
    @trade = params[:trade]

    @buy_coins, @observe_coins = helpers.insert_extra_values_from( Coin.all )
  end
end
