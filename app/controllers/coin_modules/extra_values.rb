module CoinModules 
  module ExtraValues
    def dump_grade_in( changes, total = 0, dumps = 0 )
      changes.each do | change |
        total += change.abs
        dumps += change.abs if change < 0
      end

      helpers.percentage_between( dumps, total )
    end
    
    def get_trend_change_of( prices, count )
      count -= count * 2 + 1
    
      prices['prices'][count..-1]
    end

    def insert_trade_grade_of( coins )
      coins.each_with_index do |coin|
        grade_a = coin[ 'trend_8h' ][ 'dump_grade_8h' ]
        grade_b = coin[ 'trend_45m' ][ 'dump_grade_45m' ]

        total = ( grade_a * 0.30 ) + ( grade_b * 0.70 )

        coin.store( 'trade_grade', total )
      end
    end

    #analyzes three price changes trajectory
    def score_15m_trajectory_of( prices, score = 0 )
      prices.each_with_index do | price, index | 
        next if index == 0
    
        price_a = prices[ index-1 ][1]
    
        price_b = price[1]

        if index == 1 && price_b > price_a
          score += 1
        elsif index == 2 && price_b > price_a
          score += 2
        end
      end
      
      score
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
                                 'last_change' => trend_changes[-1],
                                 'dump_grade_45m' => dump_grade_in( trend_changes ),
                                 'trajectory_45m' => score_15m_trajectory_of( trend[8..-1] ) } )
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
    
    def insert_8_hr_trend_of( coin, prices )
      trends = get_trend_change_of( prices, 99 )

      trend_changes = market_8h_changes( trends )
    
      coin.store( 'trend_8h', { 'changes' => trend_changes,
                                'dump_grade_8h' => dump_grade_in( trend_changes ),
                                'trajectory_8h' => score_15m_trajectory_of( trends[97..-1] ) } )
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
      
        insert_coin_gains( coin )
      
        insert_8_hr_trend_of( coin, prices )
      
        insert_45_min_trend_of( coin, prices )

        insert_history_vs_current_price( coin, prices )
      end
      insert_trade_grade_of( coins )
      
      coins
    end
  end 
end