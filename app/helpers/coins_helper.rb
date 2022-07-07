module CoinsHelper
  def sum_price_changes(prices, x = 0)
    prices.each { |p| x += p.abs }

    x
  end
  
  def filter_trade( coins, trade_coin )
    trade_coin = coins.find { | c | c[ 'id' ] == trade_coin }

    coins -= [ trade_coin ]
    
    coins = coins.sort_by { | k | k[ 'trade_grade' ] }.reverse

    coins.unshift( trade_coin )
  end

  def is_user_owned?( coin )
    !coin.fuse_count.nil? && coin.fuse_count > 0
  end

  def show_ids( coin )
    "#{ coin.coin_name }(#{ coin.coin_sym })"
  end

  def user( coin )
    coin_id = coin.is_a?( String ) ? coin : coin[ 'id' ]
    
    Coin.find_by(coin_id: coin_id) 
  end

  def current_price_of( coin, currency = 'php' )
    case coin
    when String
      market( coin, currency )['current_price'].to_f
    else
      coin['current_price'].to_f
    end
  end
end
