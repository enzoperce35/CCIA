class HomeController < ApplicationController
  before_action :authenticate_user!

  def observe
    change_observation_status_of( params[:coin_to_observe] )

    redirect_to root_path(observe: true)
  end
  
  def index
    @all = params[:all]
    
    change_observation_status_of( params[:coin_to_observe] ) if params[:coin_to_observe].present?
    
    @coin_ids =
    if @all
      Coin.pluck('coin_id').join(', ')
    else
      Coin.where(observed?: true).pluck('coin_id').join(', ')
    end
    
    @coins = helpers.insert_extra_values_from( @coin_ids )
    
    @timer = params[:auto_timer].present? ? set_timer_for( @coins ) : 1000
  end

  private

  def set_timer_for( coins )
    coins.count * 4
  end

  def change_observation_status_of( coin )
    coin = Coin.find_by( id: coin )

    coin.update(observed?: coin.observed? ? false : true)
  end
end
