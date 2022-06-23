class HomeController < ApplicationController
  #before_action :authenticate_user!
  
  def index
    @trending = helpers.client.trending_searches
  end

  private
end
