class HomeController < ApplicationController
  before_action :authenticate_user!

  def observe
    change_observation_status_of( params[:coin_to_observe] )

    redirect_to root_path(observe: true)
  end
  
  def index
    @all = params[:all]
    @trade_coin = params[:coins][:trade] if params[:coins].present?
    
    change_observation_status_of( params[:coin_to_observe] ) if params[:coin_to_observe].present?
    reset_observed( params[:unobserve] ) if params[:unobserve].present?
    
    @coin_ids =
    if @all
      Coin.pluck( 'coin_id' ).join(', ')
    elsif @trade_coin.present?
      Coin.where( owned?: false ).pluck( 'coin_id' ).push( @trade_coin ).join(', ')
    else
      owned = Coin.where( owned?: true ).pluck( 'coin_id' )
      observed = Coin.where( observed?: true ).pluck( 'coin_id' )
      
      ( owned + observed ).join(', ')
    end
    
    client = helpers.client
    @coins = helpers.insert_extra_values_from( @coin_ids, client )
    
    @timer = params[:auto_timer].present? ? set_timer_for( @coins ) : 1000
  end

  private

  def set_timer_for( coins )
    coins.count * 3
  end

  def reset_observed( coins )
    coins = coins.split(', ')

    coins.each do |coin|
      coin = Coin.find_by(coin_id: coin)

      next if coin.owned?

      coin.update(observed?: false)
    end
  end

  def change_observation_status_of( coin )
    coin = Coin.find_by( id: coin )

    coin.update(observed?: coin.observed? ? false : true)
  end
end
