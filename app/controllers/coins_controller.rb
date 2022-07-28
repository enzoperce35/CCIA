class CoinsController < ApplicationController

  include CoinModules::ViewCoins
  include CoinModules::ExtraValues
  include CoinModules::MarketStatus
  
  def new
    @coin = Coin.new
    @coins = helpers.assemble(helpers.client.coins_list)
  end

  def create
    coin = Coin.create(coin_params)
    market_coin = helpers.market( coin )
    
    if coin.save
      insert_initial_data_of( market_coin, coin )
      
      redirect_to home_path, notice: "added new coin: #{ helpers.show_ids( coin ) }"
    else
      redirect_back(fallback_location: root_path, notice: "coin not saved")
    end
  end

  def index
    actives = params[ :actives ]
    inactives = params[ :inactives ]
    @trade_coin = params[:coins][:trade] if params[:coins].present?
    @auto_timer = params[ :auto_timer ]

    @user_view = fetch_user_view( actives, inactives, @trade_coin )

    @coin_ids = fetch_user_coins( @user_view, @trade_coin )

    @coins = insert_extra_values_from( @coin_ids, helpers.client )
    
    @market_status = analyze_current_market_of( @coins ) if @user_view == 'trade_view'

    @timer = set_timer_for( @coins )
  end

  def show
    @selected_coin = Coin.find( params[ :id ] )
  end

  def destroy
    coin = Coin.find( params[:id] )

    if coin.destroy
      redirect_to home_path, notice: "#{ helpers.show_ids( coin ) } deleted"
    else
      redirect_back( fallback_location: root_path, notice: 'delete failed' )
    end
  end

  def edit
    @coin = Coin.find( params[ :id ] )
  end

  def update
    coin = Coin.find( params[:id] )

    if coin.update( coin_params )
      notice = 'successfuly updated ' + helpers.show_ids( coin )
      
      if coin.is_observed
        redirect_to root_path, notice: notice
      else
        redirect_to home_path, notice: notice
      end
    else
      redirect_back( fallback_location: root_path, notice: 'coin update failed' )
    end
  end

  def observe
    change_observation_status_of( params[ :coin_to_observe ] )

    redirect_to root_path( observe: true )
  end

  def trade_coin
    @user_coins = Coin.owned
  end

  def make_trade
    buy = helpers.user( params[ :buy ] )
    sell = helpers.user( params[ :sell ])
    tp = params[ :tp ]

    buy.update( fuse_count: buy.fuse_count += 1, short_gain: helpers.current_price_of( buy.coin_id ), profit_take: 10, usd_trade_price: helpers.current_price_of( buy.coin_id, 'usd' ) )
    sell.update( fuse_count: sell.fuse_count -= 1, short_gain: helpers.current_price_of( sell.coin_id ), profit_take: nil, is_observed: true)

    high, low = helpers.generate_margins( buy )

    redirect_to root_path, method: 'get', notice: "set #{ buy.coin_sym }: time => #{ tp } high => #{ high } - low => #{ low }" 
  end

  def gain_reset
    coins = Coin.active.pluck( 'coin_id' ).join(', ')

    coins = helpers.client.markets( coins, vs_currency: 'php' )

    if params[ :gain ] == 'short'
      coins.each { | c | helpers.user( c ).update( short_gain: c[ 'current_price' ] ) }
    else
      coins.each { | c | refresh_gain_data( helpers.user( c ),  c[ 'current_price' ] ) }
    end

    redirect_to home_path
  end

  def activate_coin
    coin = Coin.find_by( coin_id: params[ :to_activate ] )

    market = helpers.market( coin )

    coin.update( is_active: true, coin_name: market[ 'name' ], coin_sym: market[ 'symbol' ], long_gain: market[ 'current_price' ], short_gain: market[ 'current_price' ] )

    redirect_to root_path( actives: true )
  end

  def price_range
    Coin.active.each do | coin |
      minmax = helpers.client.hourly_historical_price( coin.coin_id, currency: 'php', days: 30 )['prices'].map { |c| c[ 1 ] }.minmax
      
      coin.update( min_max: minmax )
    end

    redirect_to home_path, notice: 'Price ranges successfuly catched'
  end

  private

  def refresh_gain_data( coin, price )
    coin.update( long_gain: price, short_gain: price )
  end

  def insert_initial_data_of( market_coin, user_coin )
    user_coin.update( coin_name: market_coin[ 'name' ], coin_sym: market_coin[ 'symbol' ],
                      long_gain: market_coin[ 'current_price' ], short_gain: market_coin[ 'current_price' ] )
  end

  def set_timer_for( coins )
    coins.is_a?( String ) ? 10000 : coins.count * 2.5
  end

  def change_observation_status_of( coins )
    coins =  coins.split(', ')

    coins.each do |coin|
      coin = Coin.find_by( coin_id: coin )

      next if helpers.is_user_owned?( coin ) || coin.coin_type == 'stablecoin'

      coin.update( is_observed: coin.is_observed? ? false : true )
    end
  end

  def coin_params
    params.require(:coin).permit( :coin_id, :coin_type, :is_observed, :is_active, :long_gain, :short_gain, :holdings, :usd_trade_price, :fuse_count )
  end
end
