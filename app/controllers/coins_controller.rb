class CoinsController < ApplicationController
  def new
    @status = params[:status]
    @coin = Coin.new
    @coins = helpers.assemble(helpers.client.coins_list)
  end

  def create
    coin = Coin.create(coin_params)
    
    if coin.save
      add_entry_price_of(coin)
      
      redirect_to root_path, notice: "new coin saved!"
    else
      redirect_back(fallback_location: root_path, notice: "coin not saved")
    end
  end


  def show
    @coin = Coin.find( params[:id] )

    @market = helpers.insert_values_from(@coin)
  end

  def destroy
    coin = Coin.find( params[:id] )

    if coin.destroy
      redirect_to root_path, notice: "#{coin.coin_id} deleted"
    else
      redirect_back(fallback_location: root_path, notice: 'delete failed')
    end
  end


  def show_trade
    buy = Coin.find_by(coin_id: params[:buy])
    sell = Coin.find_by(coin_id: params[:sell])

    @buy, @sell = helpers.insert_extra_values_from( [ buy, sell ] ).flatten(1)
  end

  def trade
    buy = Coin.find_by(coin_id: params[:buy])
    sell = Coin.find_by(coin_id: params[:sell])
    
    coin = market( sell )
    
    sell_price = coin['current_price']
      
    buy.update(status: 'observe', value: nil)
    sell.update(status: 'buy', value: sell_price)

    redirect_to root_path
  end

  private

  def add_entry_price_of(coin)
    coin.update(value: current_price_of( market(coin) ) ) if coin.status == 'buy'
  end

  def market(coin)
    helpers.market(coin)
  end

  def current_price_of( market_coin )
    helpers.current_price_of( market_coin )
  end

  def coin_params
    params.require(:coin).permit( :coin_id, :status, :value )
  end
end
