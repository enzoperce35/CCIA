module CoinsHelper
 
  def sum_price_changes(prices, x = 0)
    prices.each { |p| x += p[1]}

    x
  end

  def get_grades( coins, price_change, price_gain )
    coins.each do |coin|
      grade_a = percentage_between( coin[ 'market_cap_change_percentage_24h' ], price_change.abs )
      grade_b = 10 - percentage_between( coin[ 'vs_24h' ], price_gain )

      total = ( grade_a * 0.70 ) + ( grade_b * 0.30 ) 

      coin.store( 'trade_grade', total )
    end
  end

  def insert_trade_grade_of( coins, price_change = 0, price_gain = 0)
    coins.each do |coin|
      price_change += coin[ 'market_cap_change_percentage_24h' ]
      price_gain += coin[ 'vs_24h' ]
    end

    get_grades( coins, price_change, price_gain )
  end

  def analyze_43m_market( trends, arr = [] )
    trends.each_with_index do | trend, index |
      next if index == 0
    
      price_a = trends[ index-1 ]
    
      price_b = trend

      change_indicator = price_a <= price_b ? 'green' : 'red'
    
      arr << [ change_indicator, ( percentage_between( price_b, price_a ) - 100 ).abs ]
    end
    arr
  end

  def analyze_8h_market( trends, arr = [] )
    trends = trends.each_slice(10).to_a

    trends.each do |trend|
      tail = trend.shift
      head = trend.pop

      indicator = tail > head ? 'red' : 'green'

      arr << [ indicator, ( percentage_between( head, tail ) - 100 ).abs ]
    end

    arr
  end

  def get_trend_change_of( prices, count, arr = [] )
    count -= count * 2 + 1
    
    prices = prices['prices'][count..-1]
    
    prices.each { |_, price|  arr << price } 
      
    arr
  end

  def insert_8_hr_trend_of( coin, prices )
    trends = get_trend_change_of( prices, 99 )
    
    coin.store('trend_8h', analyze_8h_market( trends ) )
   
    coin
  end
  
  def insert_43_min_trend_of( coin, prices )
    trends = get_trend_change_of( prices, 10 )
      
    coin.store('trend', analyze_43m_market( trends ) )
   
    coin
  end

  def insert_15_min_trajectory_of( coin, prices )
    trends = get_trend_change_of( prices, 5 )

    tail = trends.shift
    head = trends.pop

    indicator = tail > head ? 'red' : 'green'

    difference = percentage_between( head, tail ) - 100
   
    coin.store( 'trajectory', [ indicator, difference / 15 ] )
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

      insert_15_min_trajectory_of( coin, prices )

      insert_43_min_trend_of( coin, prices )

      insert_8_hr_trend_of( coin, prices )
    end
    insert_trade_grade_of( coins )
  end
end
