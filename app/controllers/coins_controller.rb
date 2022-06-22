class CoinsController < ApplicationController
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
    all = params[:all]
    @trade_coin = params[:coins][:trade] if params[:coins].present?
    @auto_timer = params[ :auto_timer ]

    @user_view = fetch_user_view( all, @trade_coin )

    @coin_ids = fetch_user_coins( @user_view, @trade_coin )

    @coins = helpers.insert_extra_values_from( @coin_ids, helpers.client )
    
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
        redirect_to home_path
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
    @user_coins = Coin.where( "fuse_count > ?", 0 )
  end

  def make_trade
    buy = helpers.user( params[ :buy ] )
    sell = helpers.user( params[ :sell ])

    buy.update( fuse_count: buy.fuse_count += 1, usd_trade_price: helpers.current_price_of( buy.coin_id, 'usd' ))
    sell.update( fuse_count: sell.fuse_count -= 1, is_observed: true)

    high, low = helpers.generate_margins( buy )

    redirect_to root_path, method: 'get', notice: "set #{ buy.coin_sym }: high => #{ high } - low => #{ low }" 
  end

  def gain_reset
    coins = Coin.pluck( 'coin_id' ).join(', ')

    coins = helpers.client.markets( coins, vs_currency: 'php' )

    if params[ :gain ] == 'short'
      coins.each { | c | helpers.user( c ).update( short_gain: c[ 'current_price'] ) }
    else
      coins.each { | c | helpers.user( c ).refresh_gain_data( c[ 'current_price' ]) }
    end

    redirect_to home_path
  end

  private

  def fetch_user_view( all, trade )
    if all
      'coins_view'
    elsif trade.present?
      'trade_view'
    else
      'observe_view'
    end
  end

  def fetch_user_coins( view, trade_coin = nil )
    case view
    when 'coins_view'
      Coin.pluck( 'coin_id' ).join(', ')
    when 'trade_view'
      Coin.reserved.pluck( 'coin_id' ).push( @trade_coin ).join(', ')
    else
      ( Coin.owned + Coin.observed ).pluck( 'coin_id' ).join(', ')
    end
  end

  def refresh_gain_data( price )
    self.update( long_gain: price, short_gain: price )
  end

  def insert_initial_data_of( market_coin, user_coin )
    user_coin.update( coin_name: market_coin[ 'name' ], coin_sym: market_coin[ 'symbol' ],
                      long_gain: market_coin[ 'current_price' ], short_gain: market_coin[ 'current_price' ] )
  end

  def set_timer_for( coins )
    coins.is_a?( String ) ? 10000 : coins.count * 3
  end

  def change_observation_status_of( coins )
    coins =  coins.split(', ')

    coins.each do |coin|
      coin = Coin.find_by( coin_id: coin )

      next if helpers.is_user_owned?( coin )

      coin.update( is_observed: coin.is_observed? ? false : true )
    end
  end

  def coin_params
    params.require(:coin).permit( :coin_id, :coin_type, :is_observed, :long_gain, :short_gain, :holdings, :usd_trade_price, :fuse_count )
  end
end
