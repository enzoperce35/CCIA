class HomeController < ApplicationController
  before_action :authenticate_user!
  
  def index
    @trade = params[:trade]

    @coins = helpers.insert_extra_values_from( Coin.all )

    @buy_coins, @observe_coins = helpers.arrange(@coins)
  end
end
