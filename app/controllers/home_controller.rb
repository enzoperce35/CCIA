class HomeController < ApplicationController
  before_action :authenticate_user!
  
  def index
    @selected_coin = params[:selected]
    @observe = params[:observe]
    @coins = helpers.insert_extra_values_from( Coin.all )
  end
end
