module CoinsHelper
 
  def sum_price_changes(prices, x = 0)
    prices.each { |p| x += p.abs }

    x
  end

  def grade_15m_trajectory_of( coin )
    indicator, trajectory = coin[ 'trajectory' ]

    if indicator == 'red'
      50 - trajectory.abs
    else
      50 + trajectory.abs
    end
  end

  def insert_trade_grade_of( coins )
    coins.each_with_index do |coin|
      grade_a = coin[ 'score_8h' ]
      grade_b = coin[ 'score_30m' ]
      grade_c = grade_15m_trajectory_of( coin )

      total = ( grade_a * 0.10 ) + ( grade_b * 0.20 ) + ( grade_c * 0.60 )

      coin.store( 'trade_grade', total )
    end
  end

  def analyze_43m_market( trends, arr = [] )
    trends.each_with_index do | trend, index |
      next if index == 0
    
      price_a = trends[ index-1 ][1]
    
      price_b = trend[1]
  
      arr << percentage_between( price_b, price_a ) - 100
    end
    arr
  end

  def analyze_8h_market( trends, arr = [] )
    trends = trends.each_slice(10).to_a

    trends.each do |trend|
      tail = price_of( trend, 0 )
      head = price_of( trend, -1 )

      arr <<  percentage_between( head, tail ) - 100
    end

    arr
  end

  def get_trend_change_of( prices, count )
    count -= count * 2 + 1
    
    prices['prices'][count..-1]
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

  def sum_score_of( changes, total = 0, dumps = 0 )
    changes.each do | change |
      total += change.abs
      dumps += change.abs if change < 0
    end

    percentage_between(dumps, total)
  end

  def time_difference_of( time_a, time_b )
    time_a = Time.parse( DateTime.strptime( time_a[0].to_s, "%Q" ).to_s )
    time_b = Time.parse( DateTime.strptime( time_b[0].to_s, "%Q" ).to_s )

    (time_b - time_a) / 60
  end

  # average duration of 3 trends is '9 - 10 min', coingecko price info delay avg is '5 min'
  def insert_15m_price_trajectory_of( coin, prices )
    trend = get_trend_change_of( prices, 2 )

    tail = trend[0]
    head = trend[-1]

    indicator = price_of( tail ) > price_of( head ) ? 'red' : 'green'

    time_difference = time_difference_of( tail, head )

    trajectory = ( (percentage_between( price_of( tail ), price_of( head ) ) - 100) / time_difference ).abs
   
    coin.store( 'trajectory', [ indicator, trajectory ] )
  end

  def insert_analysis_of_8h_trend_of( coin )
    changes = coin['trend_8h']

    coin.store( 'score_8h', sum_score_of( changes ) )
  end
  
  def insert_analysis_of_30m_trend_of( coin )
    changes = coin['trend'][0..6]

    coin.store( 'score_30m', sum_score_of( changes ) )
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

      insert_8_hr_trend_of( coin, prices )
      
      insert_43_min_trend_of( coin, prices )
      
      insert_analysis_of_30m_trend_of( coin )
      
      insert_analysis_of_8h_trend_of( coin )

      insert_15m_price_trajectory_of( coin, prices )
    end
    insert_trade_grade_of( coins )
    coins
  end
end
