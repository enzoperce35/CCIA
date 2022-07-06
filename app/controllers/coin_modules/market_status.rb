require 'bigdecimal'

class Numeric
  def percent_of(n)
    self.to_f * n.to_f / 100.0
  end
end

module CoinModules
  module MarketStatus
    def monitor_movement( new_status )
      new_status.keys.each do | key |
        market = MarketRun.find_by( name: key )
        value = new_status[ key ][0]
        
        movements = market.movement

        market.update( movement: movements.push( value ) )
      end
    end
    
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

    def fetch_market( status )
      bullish, bearish = status.values.map { |s| s[ 1 ] }

      status = 
      if bullish >= 100
        'bullish'
      elsif bearish >= 100
        'bearish'
      else
        'normal'
      end

      MarketRun.find_by( name: status )
    end
    
    def restart_run
      MarketRun.update_all( started: DateTime.now, warmth: 0, runs: 0, movement: [] )
    end
    
    def last_market_update
      MarketRun.order( 'updated_at' )[ -1 ].updated_at
    end
    
    def last_run_is_recent?
      last_market_update > 3.minutes.ago
    end
  
    def market_run_default_is_invalid
      MarketRun.count != 3
    end
    
    def record_run_of( new_status )
      return 'Run Reports Unavailable' if market_run_default_is_invalid  #not tested
  
      restart_run unless last_run_is_recent?
      
      market_status = fetch_market( new_status )
      
      opposed_market_statuses = opposing( market_status )
  
      warm_up( market_status ) unless market_status.name == 'normal'
      
      cool_down( opposed_market_statuses )

      monitor_movement( new_status )
  
      { 'current_status' => market_status.name,
        'warmth' => market_status.warmth,
        'duration' => helpers.minute_difference_of( DateTime.now.utc, market_status.started ),
        'steady_market?' => market_is_steady?,
        'bear_runs' => MarketRun.find_by( name: 'bearish' ).runs,
        'bull_runs' => MarketRun.find_by( name: 'bullish' ).runs }
    end

    def state_percentage( value, coins )
      state_margin = 68.percent_of( coins.count )
      
      ( value / state_margin ) * 100
    end

    def analyze_market( coins, dumps = 0, pumps = 0 )
      coins.each do | coin |
        last_change = coin[ 'trend_45m' ][ 'last_change' ]
  
        last_change < 0 ? dumps += 1 : pumps +=1
      end

      { 'pumps' => pumps, 'dumps' => dumps }
    end
  
    def market_status_of( coins )
      pumps, dumps = analyze_market( coins ).values
  
      { 'bullish' => [ pumps, state_percentage( pumps, coins ) ], 'bearish' => [ dumps, state_percentage( dumps, coins ) ] }
    end
  
    def analyze_current_market_of( coins )
      coins = coins.reject { | coin | helpers.user( coin ).coin_type == 'stablecoin' }
      
      new_market_status = market_status_of( coins )

      record_run_of( new_market_status )
    end
  end
end
