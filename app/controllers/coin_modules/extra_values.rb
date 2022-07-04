module CoinModules 
  module ExtraValues
    def insert_trade_grade_of( coins )
      coins.each_with_index do |coin|
        grade_a = coin[ 'score_8h' ]
        grade_b = coin[ 'score_30m' ]

        total = ( grade_a * 0.30 ) + ( grade_b * 0.70 )

        coin.store( 'trade_grade', total )
      end
    end

    def analyze_43m_market( trends, arr = [] )
      trends.each_with_index do | trend, index |
        next if index == 0
    
        price_a = trends[ index-1 ][1]
    
        price_b = trend[1]
  
        arr << helpers.percentage_between( price_b, price_a ) - 100
      end
      arr
    end

    def price_of( trend, index = nil )
      if index.nil?
        trend[ 1 ]
      else
        trend[ index ][1]
      end
    end

    def analyze_8h_market( trends, arr = [] )
      trends = trends.each_slice(10).to_a

      trends.each do |trend|
        tail = price_of( trend, 0 )
        head = price_of( trend, -1 )

        arr <<  helpers.percentage_between( head, tail ) - 100
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
      
      coin.store( 'trend', analyze_43m_market( trends ) )
   
      coin
    end

    def sum_score_of( changes, total = 0, dumps = 0 )
      changes.each do | change |
        total += change.abs
        dumps += change.abs if change < 0
      end

      helpers.percentage_between(dumps, total)
    end

    def time_difference_of( time_a, time_b )
      time_a = Time.parse( DateTime.strptime( time_a[0].to_s, "%Q" ).to_s )
      time_b = Time.parse( DateTime.strptime( time_b[0].to_s, "%Q" ).to_s )

      (time_b - time_a) / 60
    end

    def analyze_trajectory( patterns )

      case patterns.join
      when 'upupup'
        'solid upward'
      when 'downdowndown'
        'solid downward'
      when'downupup'
        'upward'
      when 'updowndown'
        'downward'
      when 'upupdown'
        'broken up'
      when 'downwdownup'
        'broken down'
      else
        'volatile'
      end
    end

    def analyze_trend( prices, patterns = [] )
      prices.each_with_index do | price, index | 
        next if index == 0
    
        price_a = prices[ index-1 ][1]
    
        price_b = price[1]

        traj = 
          if price_a > price_b
            'down'
          elsif price_a < price_b
            'up'
          else
            'even'
          end

        patterns << traj
      end

      analyze_trajectory( patterns )
    end

    # average duration of 3 trends is '9 - 10 min', coingecko price info delay avg is '5 min'
    def insert_15m_price_trajectory_of( coin, prices )
      trend = get_trend_change_of( prices, 3 )

      tail = trend[1]
      head = trend[-1]

      time_difference = time_difference_of( tail, head )
    
      # this part starting here is complicated but it works
      change = ( helpers.percentage_between( price_of( tail ), price_of( head ) ) - 100 ) / time_difference

      indicator = change < 0 ? 'green' : 'red'

      coin.store( analyze_trend( trend ), [ indicator, change.abs ] )
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
      helpers.percentage_between( helpers.current_price_of( market_coin ), user_price ) - 100
    end
    
    def insert_coin_gain( market_coin, gain = '' )
      user_coin = helpers.user( market_coin )
      user_price = gain == 'long' ? user_coin.long_gain : user_coin.short_gain
        
      if user_price.nil?
        market_coin.store( "#{ gain }_gain", 'N/A' )
      else
        market_coin.store( "#{ gain }_gain", gain_of( market_coin, user_price ) )
      end
    end  
      
    def get_difference( high, low, current )
      range = high - low
  
      current -= low
  
      helpers.percentage_between(current, range)
    end

    def low_24h(coin)
      coin['low_24h']
    end
  
    def high_24h(coin)
      coin['high_24h']
    end
  
    def insert_current_vs_24h_prices_of( coin )
      difference = get_difference( high_24h( coin ), low_24h( coin ), helpers.current_price_of( coin ) )
  
      coin.store( "vs_24h", difference )
    end
  
    def insert_extra_values_from( coins, client_user )
      return 'No Coin To Observe' if coins.blank?

      coins = client_user.markets( coins, vs_currency: 'php' )
    
      coins.map do |coin|
        prices = client_user.minutely_historical_price( coin[ 'id' ] )
      
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
end