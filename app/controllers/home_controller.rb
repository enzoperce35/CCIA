require 'coingecko_ruby'

class HomeController < ApplicationController
  before_action :authenticate_user!
  
  def index
    @client = CoingeckoRuby::Client.new
  end
end
