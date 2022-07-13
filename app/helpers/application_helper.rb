require 'bigdecimal'

class Numeric
  def percent_of(n)
    self.to_f * n.to_f / 100.0
  end
end

module ApplicationHelper
  def average_price_change( market_coins, pos = [], neg = [] )
    market_coins = market_coins.reject { | c | user( c ).coin_type == 'stablecoin' }

    market_coins.each { | m | m[ 'price_change_percentage_24h' ] > 0 ? pos << m[ 'price_change_percentage_24h' ] : neg << m[ 'price_change_percentage_24h' ] }

    ( ( pos.sum - neg.sum.abs ) / market_coins.count )
  end

  def score_move( moves, m1 = 0, m2 = 0 )
    return 0 if moves.count <= 1
    
    m1 += moves[0] > moves[1] ? 0 : 1
    
    if moves.count == 3
      m2 += moves[1] > moves[2] ? 0 : 2
    end
    
    m1 + m2
  end
  
  def run_scores( runs = {} )
    market_runs = MarketRun.where.not( name: 'normal' )

    market_runs.each do | run |
      movement = run.movement.chunk_while(&:==).map(&:first)

      movement = movement[-3..-1] if movement.count >= 3

      runs.store( run.name, score_move( movement ) )
    end
    runs
  end
  
  def minute_difference_of( time_a, time_b )
    ( ( time_a.to_time.to_i - time_b.to_time.to_i ) / 60 ).round
  end
  
  def scientific_notation?(number)  #inactive
    number.to_s.include?('-')
  end
  
  def humanize_price(number)
    if scientific_notation?(number)
      "%.8f" % number
    else
      number
    end
  end

  def count_decimals( float )
    bd = BigDecimal( float.to_s )

    zeros = bd.exponent < 0 ? bd.exponent.abs : 0

    zeros + 4
  end

  def button_color( coin )
    trajectory = coin.keys[ 33 ]
  
    if [ 'solid upward', 'upward', 'broken down' ].include?( trajectory )
      "btn btn-outline-success btn-sm"
    elsif [ 'solid downward', 'downward', 'broken up' ].include?( trajectory )
      "btn btn-outline-danger btn-sm"
    else
      "btn btn-outline-dark btn-sm"
    end
  end

  def run_info_color( duration )

    size = 
    case duration.to_s.size
    when 1
      'small;'
    when 2
      'x-small;'
    else
      'xx-small;'
    end

    "font-style" + ":italic;"  +  "color:" + "black;" + "font-size:" + size
  end

  def border_color( status )
    case status
    when 'bearish'
      '1.2px solid red'
    when 'bullish'
      '1.2px solid green'
    else
      '1px solid'
    end
  end

  def pattern_color( trend )
    case trend
    when 'bullish'
      'green;'
    when 'bearish'
      'red;'
    else
      'gold;'
    end
  end

  def generate_margins( coin )
    coin = Coin.find_by( coin_id: coin ) if coin.is_a?( String )
    tp = coin.profit_take

    usd_price = coin.usd_trade_price

    return nil if tp.nil? || !usd_price.is_a?( Float )
    
    [ humanize_price( ( 100 + tp ).percent_of( usd_price ).round( count_decimals( usd_price ) ) ),
      humanize_price( 97.percent_of( usd_price ).round( count_decimals( usd_price ) ) ) ]
  end

  def find_focus
    user_coins = Coin.owned

    return Coin.first.coin_id if user_coins.count.zero?

    middle_coin = ( user_coins.count / 2 ).to_i

    user_coins[ middle_coin ].coin_id
  end

  def value_color( value )
    value < 0 ? 'red' : 'green'
  end

  def uptrending?( coin )
    traj_15m = coin[ 'trend_45m' ][ 'trajectory_15m' ]
    trend_30m = 100 - coin[ 'trend_45m' ][ 'dump_grade_30m' ]

    ( ( trend_30m >= TradeSetting.first.pump_30m ) && ( traj_15m >= 2 ) ) ||
    ( ( trend_30m >= TradeSetting.first.pump_30m - 5 ) && ( traj_15m == 3 ) )
  end

  def uptrend_anomaly( coin, apc )
    coin[ 'price_change_percentage_24h' ] - apc
  end

  def selected_for_trade?( coin, index, apc )
    return false if index == 0
    
    traj_score_45m = coin[ 'trend_45m' ][ 'trajectory_15m' ]

    time_mark = coin[ 'last_trend' ][ 'time_mark' ]

    dump_8h = coin[ 'trend_8h'][ 'dump_grade']

    ( ( time_mark <= TradeSetting.first.time_mark ) &&
      ( uptrend_anomaly( coin, apc ) >= TradeSetting.first.uptrend_anomaly ) &&
      ( uptrending?( coin ) ) &&
      ( coin[ 'vs_24h' ] <= TradeSetting.first.vs_24h ) &&
      ( dump_8h >= TradeSetting.first.dump_8h ) ) ||

    ( ( time_mark <= 10 ) && ( coin[ 'trade_grade' ] > 85 ) && ( traj_score_45m >= 2 ) && ( apc < -5 ) )
  end

  def trend_changes_of( coin, trend = nil )
    case trend
    when '8hr'
      coin[ 'trend_8h' ][ 'changes' ]
    when '45m'
      coin[ 'trend_45m' ][ 'changes' ]
    end
  end

  def break_down( trend )
    case trend
    when 3
      'uptrending'
    when 2
      'upward'
    when 1
      'downward'
    else
      'downtrending'
    end
  end

  def no_user_coin_yet?
    Coin.count.zero?
  end

  def no_displayable?( coins )
    coins.is_a?( String )
  end

  def percentage_between( price_a, price_b )
    ((price_a.to_f / price_b.to_f)  * 100).round(2)
  end

  def assemble(list)
    list.map do |h|
      name = h['name'] + '( ' + h['symbol'] + ' )' + ' ' + h['id']

      [name, h['id']]
    end
  end

  def market( user_coin, currency = 'php' )
    coin_id = user_coin.is_a?(String) ? user_coin : user_coin.coin_id
    
    client.markets( coin_id, vs_currency: currency ).pop
  end

  def client
    CoingeckoRuby::Client.new
  end
end
