class HomeController < ApplicationController
  #before_action :authenticate_user!
  
  def index
    @coins = Coin.all
  end

  private
end
