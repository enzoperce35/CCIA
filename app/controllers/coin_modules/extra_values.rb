module CoinModules 
  module ExtraValues
    def get_trend_change_of( prices, count )
      count -= count * 2 + 1
    
      prices['prices'][count..-1]
    end

    def second_difference_of( last_timestamp )
      time_a = Time.parse( DateTime.strptime( last_timestamp.to_s, "%Q" ).to_s )
      time_b = Time.parse( DateTime.now.utc.to_s )

      time_b - time_a
    end

    def insert_history_vs_current_price( coin, prices )
      last_timestamp, last_price = prices['prices'][-1]

      coin.store( 'last_trend', { 'time_mark' => second_difference_of( last_timestamp ), 'price' => last_price } )
    end

    def market_45m_changes( trends, arr = [] )
      trends.each_with_index do | trend, index |
        next if index == 0
    
        price_a = trends[ index-1 ][1]
    
        price_b = trend[1]
  
        arr << helpers.percentage_between( price_b, price_a ) - 100
      end
      arr
    end

    def insert_45_min_trend_of( coin, prices )
      trend = get_trend_change_of( prices, 10 )

      trend_changes = market_45m_changes( trend )
      
      coin.store( 'trend_45m', { 'changes' => trend_changes,
                                 'last_change' => trend_changes[-1] } )
    end

    def market_8h_changes( trends, arr = [] )
      trends = trends.each_slice(10).to_a

      trends.each do | trend |
        tail = trend[0][1]
        head = trend[-1][1]

        arr <<  helpers.percentage_between( head, tail ) - 100
      end
      arr
    end

    def analyze_trend( minmax, upward = 0, downward = 0 )
      minmax.each_with_index do | arr, index |
        next if index == 0
    
        arr_a_max = minmax[ index-1 ][ 1 ]
        
        arr_a_min = minmax[ index-1 ][ 0 ]
    
        arr_b_max = arr[ 1 ]
        
        arr_b_min = arr[ 0 ]
  
        upward += 1 if ( arr_b_max > arr_a_max ) && ( arr_b_min > arr_a_min )
        
        downward += 1 if ( arr_b_max < arr_a_max ) && ( arr_b_min < arr_a_min )
      end

      if upward == 3
        'upward'
      elsif downward == 3
        'downward'
      else
        'volatile'
      end
    end
    
    def catch_hl( trends, arr = [] )
      trends.each do | trend |
        arr << trend.map { | t | t[1] }.minmax
      end
      
      arr
    end

    def coin_trajectory( coin, trends )
      trends = trends.each_slice( 25 ).to_a
      
      minmax = catch_hl( trends )
      
      analyze_trend( minmax )
    end
    
    def insert_8_hr_trend_of( coin, prices )
      trends = get_trend_change_of( prices, 99 )

      trend_changes = market_8h_changes( trends )
    
      coin.store( 'trend_8h', { 'changes' => trend_changes,
                                'trajectory_8h' => coin_trajectory( coin, trends ) } )
    end
    
    def insert_coin_gains( market_coin, gains = [ 'long_gain', 'short_gain' ] )
      return nil if gains.count.zero?
      
      gain = gains.pop
      
      user_coin = helpers.user( market_coin )
      
      user_price = gain == 'long_gain' ? user_coin.long_gain : user_coin.short_gain
        
      market_coin.store( gain, user_price.nil? ? 'N/A' : helpers.percentage_between( market_coin[ 'current_price' ], user_price ) - 100 )

      insert_coin_gains( market_coin, gains )
    end  
      
    def get_difference( high, low, current )
      range = high - low
  
      current -= low
  
      helpers.percentage_between(current, range)
    end
    
    def insert_current_vs_30d_prices_of( coin )
      user_coin = helpers.user( coin )
      
      difference = get_difference( user_coin.min_max[ 1 ].to_f, user_coin.min_max[ 0 ].to_f, helpers.current_price_of( coin ) )
  
      coin.store( "vs_30d",  difference )
    end
    
    def insert_current_vs_24h_prices_of( coin )
      difference = get_difference( coin[ 'high_24h' ], coin[ 'low_24h' ], helpers.current_price_of( coin ) )
  
      coin.store( "vs_24h", difference )
    end
  
    def insert_extra_values_from( coins, client_user )
      return 'No Coin To Observe' if coins.blank?

      coins = client_user.markets( coins, vs_currency: 'php' )
    
      coins.map do |coin|
        prices = client_user.minutely_historical_price( coin[ 'id' ] )

        insert_current_vs_24h_prices_of( coin )
        
        insert_current_vs_30d_prices_of( coin )
        
        insert_coin_gains( coin )
      
        insert_8_hr_trend_of( coin, prices )
      
        insert_45_min_trend_of( coin, prices )

        insert_history_vs_current_price( coin, prices )
      end

      coins
    end
  end 
end