module CoinModules
  module MarketStatus
    def market_is_steady?
      MarketRun.warm.count.zero?
    end
    
    def is_hot?( market_status )
      market_status.warmth == 3
    end
  
    def is_warm?( market_status )
      market_status.warmth > 0
    end
  
    def cool_down( statuses )
      statuses.each do | status |
        next if status.name == 'normal'
  
        warmth = is_warm?( status ) ? status.warmth - 1 : 0
  
        status.update( warmth: warmth )
      end
    end
  
    def warm_up( market_status )
      
      warmth =
      if is_hot?( market_status )
        market_status.warmth
      else
        market_status.warmth + 1
      end
  
      
      runs = warmth == 3 ? market_status.runs += 1 : market_status.runs
      
      market_status.update( warmth: warmth, runs: runs )
    end
    
    def opposing( market_status )
      MarketRun.where( "name != ?", market_status.name )
    end
    
    def restart_run
      MarketRun.update_all( started: DateTime.now, warmth: 0, runs: 0 )
    end
  
    
    def last_market_update
      MarketRun.order( 'updated_at' )[ -1 ].updated_at
    end
    
    def last_run_is_recent?
      last_market_update > 30.minutes.ago
    end
  
    def market_run_default_is_invalid
      MarketRun.count != 3
    end
    
    def record_run_of( new_status )
      return { new_status => 'Run Reports Unavailable' } if market_run_default_is_invalid
  
      restart_run unless last_run_is_recent?
      
      market_status = MarketRun.find_by( name: new_status )
      
      opposed_market_statuses = opposing( market_status )
  
      warm_up( market_status ) unless market_status.name == 'normal'
      
      cool_down( opposed_market_statuses )
  
      { 'current_status' => market_status.name,
        'warmth' => market_status.warmth,
        'duration' => helpers.minute_difference_of( DateTime.now.utc, market_status.started ),
        'steady_market?' => market_is_steady?,
        'bear_runs' => MarketRun.find_by( name: 'bearish' ).runs,
        'bull_runs' => MarketRun.find_by( name: 'bullish' ).runs }
    end
    
    def analyze_market( coins, dumps = 0, pumps = 0 )
      coins.each do | coin |
        latest_trend = coin[ 'trend' ][ -1 ]
  
        if latest_trend < 0
          dumps += 1
        elsif latest_trend > 0
          pumps += 1
        end
      end
  
      pumps > dumps ? [ 'pump', pumps.to_f ] : [ 'dump', dumps.to_f ]
    end
  
    def market_status_of( coins )
      state, value = analyze_market( coins )
      
      value = ( value / coins.count.to_f ) * 100
  
      if state == 'pump' && value >= 68
        'bullish'
      elsif state == 'dump' && value >= 68
        'bearish'
      else
        'normal'
      end
    end
  
    def analyze_current_market_of( coins )
      new_market_status = market_status_of( coins )
  
      record_run_of( new_market_status )
    end
  end
end
