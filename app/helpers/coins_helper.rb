module CoinsHelper
 
  def sum_price_changes(prices, x = 0)
    prices.each { |p| x += p[1]}

    x
  end

  def get_grades( coins, price_change, price_gain, short_gain )
    coins.each do |coin|
      grade_a = percentage_between( coin[ 'market_cap_change_percentage_24h' ], price_change.abs )
      grade_b = 10 - percentage_between( coin[ 'vs_24h' ], price_gain )
      grade_c = percentage_between( coin[ 'short_gain' ], short_gain.abs )

      total = ( ( grade_a * 0.50 ) + ( grade_b * 0.10 ) + ( grade_c * 0.40 ) )

      coin.store( 'trade_grade', total )
    end
  end

  def insert_trade_grade_of( coins, price_change = 0, price_gain = 0, short_gain = 0 )
    coins.each do |coin|
      price_change += coin[ 'market_cap_change_percentage_24h' ]
      price_gain += coin[ 'vs_24h' ]
      short_gain += coin[ 'short_gain' ]
    end

    get_grades( coins, price_change, price_gain, short_gain )
  end

  def analyze_change_in( trends, arr = [] )
    trends.each_with_index do | trend, index |
      next if index == 0
    
      price_a = trends[ index-1 ]
    
      price_b = trend

      change_indicator = price_a <= price_b ? 'green' : 'red'
    
      arr << [ change_indicator, ( percentage_between( price_b, price_a ) - 100 ).abs ]
    end
    arr
  end

  def get_last_ten_changes_of( prices, arr = [] )
    prices = prices['prices'][-11..-1]
    
    prices.each { |_, price|  arr << price } 
      
    arr
  end
  
  def insert_price_trends_of( coin, prices )
    trends = get_last_ten_changes_of( prices )
      
    coin.store('trend', analyze_change_in( trends ) )
   
    coin
  end

  def gain_of( market_coin, user_price )
    percentage_between( current_price_of( market_coin ), user_price ) - 100
  end

  def insert_coin_gain( market_coin, gain = '' )
    user_coin = user( market_coin )
    user_price = gain == 'long' ? user_coin.trade_price : user_coin.observed_price
    
    if user_price.nil?
      market_coin.store( "#{ gain }_gain", 'N/A' )
    else
      market_coin.store( "#{ gain }_gain", gain_of( market_coin, user_price ) )
    end
  end  
  
  def get_difference( high, low, current )
    range = high - low
  
    current -= low
  
    percentage_between(current, range)
  end
  
  def insert_current_vs_24h_prices_of( market_coin )
    difference = get_difference( high_24h( market_coin ), low_24h( market_coin ), current_price_of( market_coin ) )
  
    market_coin.store( "vs_24h", difference )
  end
  
  def insert_extra_values_from( coins, client_user )
    return 'No Coin To Observe' if coins.blank?

    coins = client_user.markets( coins, vs_currency: 'php' )
    
    coins.map do |coin|
      prices = client_user.minutely_historical_price( coin['id'] )
      
      insert_current_vs_24h_prices_of( coin )
      
      insert_coin_gain( coin, 'long' )
      
      insert_coin_gain( coin, 'short' )

      insert_price_trends_of( coin, prices )
    end
    insert_trade_grade_of( coins )
  end
end
