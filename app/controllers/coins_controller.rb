class CoinsController < ApplicationController
  def new
    @coin = Coin.new
    @coins = helpers.assemble(helpers.client.coins_list)
  end

  def create
    coin = Coin.create(coin_params)
    
    if coin.save
      redirect_to root_path, notice: "new coin saved!"
    else
      redirect_back(fallback_location: root_path, notice: "coin not saved")
    end
  end

  def show
    @selected_coin = Coin.find( params[:id] )

    @user_coin = market( @selected_coin )
  end

  def destroy
    coin = Coin.find( params[:id] )

    if coin.destroy
      redirect_to root_path, notice: "#{coin.coin_id} deleted"
    else
      redirect_back(fallback_location: root_path, notice: 'delete failed')
    end
  end

  def edit_user_coin
    coin = Coin.find_by(coin_id: params[:selected])

    update_user(coin)

    redirect_to root_path, method: 'get'
  end

  def holdings
    @coin = Coin.find_by( coin_id: params[:selected] )
  end

  def update
    coin = Coin.find( params[:id] )
    selected = params[:selected]

    if coin.update( coin_params )
      if selected.present?
        redirect_to coin_path(coin), notice: 'coin updated'
      else
        redirect_to root_path, notice: 'coin updated'
      end
    else
      redirect_back(fallback_location: root_path, notice: 'coin update failed')
    end
  end

  def make_trade
    buy = Coin.find_by( coin_id: params[:coins][:buy] ) 
    sell = Coin.find_by( coin_id: params[:coins][:sell] )

    [buy, sell].each { |coin| update_user( coin ) }

    redirect_to root_path, method: 'get'
  end

  def trade_coins
    @user_coins = Coin.where(owned?: true)
    @observed_coins = Coin.where(owned?: false)
  end

  def gain_reset
    coins = params[:coins].split(', ')

    coins.each do |coin|
      sel_coin = Coin.find_by(coin_id: coin)
      
      sel_coin.update(observed_price: helpers.current_price_of( coin ) )
    end

    redirect_back(fallback_location: root_path)
  end

  private

  def update_user(coin)
    coin.update( owned?: coin.owned? ? false : true, trade_price: current_price_of( coin ) )
  end

  def market(coin)
    helpers.market(coin)
  end

  def current_price_of( market_coin )
    helpers.current_price_of( market_coin )
  end

  def coin_params
    params.require(:coin).permit( :coin_id, :owned?, :observed?, :observed_price, :on_hold )
  end
end
