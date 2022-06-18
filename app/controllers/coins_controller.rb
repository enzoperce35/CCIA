class CoinsController < ApplicationController
  def new
    @coin = Coin.new
    @coins = helpers.assemble(helpers.client.coins_list)
  end

  def create
    coin = Coin.create(coin_params)
    
    if coin.save
      reset_all_gain_data_of( coin )
      
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

  def edit
    @coin = Coin.find( params[ :id ] )
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
        redirect_to root_path, notice: 'coin updated successfuly'
      end
    else
      redirect_back(fallback_location: root_path, notice: 'coin update failed')
    end
  end

  def trade_coin
    @user_coins = Coin.where(owned?: true)
  end

  def make_trade
    buy = params[:buy]
    sell = params[:sell]

    [ buy, sell ].each { |coin| update_user( Coin.find_by( coin_id: coin ) ) }

    high, low = helpers.generate_margins( buy )

    redirect_to root_path, method: 'get', notice: "set #{ buy }: high => #{ high } - low => #{ low }" 
  end

  def gain_reset
    gain = params[:gain]
    coins = Coin.pluck( 'coin_id' ).join(', ')

    coins = helpers.client.markets( coins, vs_currency: 'php' )

    coins.each do |coin|
      if gain == 'short'
        helpers.user( coin ).update( observed_price: coin[ 'current_price'] )
      else
        reset_all_gain_data_of( coins )
      end
    end

    redirect_back(fallback_location: root_path)
  end

  private

  def reset_all_gain_data_of( coins )
    coins.each do |coin|
      price = coin[ 'current_price' ]
      
      helpers.user( coin ).update( trade_price: price, observed_price: price )
    end
  end

  def update_user(coin)
    coin.update( owned?: coin.owned? ? false : true, trade_price: helpers.current_price_of( coin.coin_id ), usd_trade_price: helpers.current_price_of( coin.coin_id, 'usd' ) )
  end

  def market(coin)
    helpers.market(coin)
  end

  def coin_params
    params.require(:coin).permit( :coin_id, :owned?, :on_hold, :coin_type, :fuse_count, :observed?, :observed_price )
  end
end
