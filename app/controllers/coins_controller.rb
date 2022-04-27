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
  end

  def destroy
    coin = Coin.find( params[:id] )

    if coin.destroy
      redirect_to root_path, notice: "#{coin.coin_id} deleted"
    else
      redirect_back(fallback_location: root_path, notice: 'delete failed')
    end
  end

  def update
    coin = Coin.find( params[:id] )
     
    answer = coin.owned? ? false : true
    
    coin.update(owned?: answer)

    redirect_to root_path, method: 'get'
  end

  private

  def market(coin)
    helpers.market(coin)
  end

  def current_price_of( market_coin )
    helpers.current_price_of( market_coin )
  end

  def coin_params
    params.require(:coin).permit( :coin_id, :owned? )
  end
end
