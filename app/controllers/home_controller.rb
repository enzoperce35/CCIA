class HomeController < ApplicationController
  before_action :authenticate_user!
  
  def index
    @observe = params[:observe]
    
    @coins = helpers.insert_extra_values_from( Coin.all )
  end
end
