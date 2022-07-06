require 'bigdecimal'

class Numeric
  def percent_of(n)
    self.to_f * n.to_f / 100.0
  end
end

module ApplicationHelper
  def average_price_change( market_coins, pos = [], neg = [] )
    market_coins = market_coins.reject { | c | user( c ).coin_type == 'stablecoin' }

    market_coins.each { | m | m[ 'market_cap_change_percentage_24h' ] > 0 ? pos << m[ 'market_cap_change_percentage_24h' ] : neg << m[ 'market_cap_change_percentage_24h' ] }

    ( (pos.sum - neg.sum.abs) / market_coins.count ) + 2
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
  
  def cast_report( record, time_covered )
    if record.bullish > 0 && record.bearish > 0
      "detected #{ record.bullish } bull runs and #{ record.bearish } bear runs from the last #{ time_covered } minutes"
    elsif record.bullish > 0
      "detected #{ record.bullish } bull runs from the last #{ time_covered } minutes"
    elsif record.bearish > 0
      "detected #{ record.bearish } bear runs from the last #{ time_covered } minutes"
    else
      "market is normal for the last #{ time_covered } minutes"
    end
  end
  
  def update_report( record, status )
    return nil if status[ 'warmth' ] != 3
    
    case status[ 'current_status' ]
    when 'bullish'
      record.update( bullish: record.bullish += 1 )
    when 'bearish'
      record.update( bearish: record.bearish += 1 )
    end
  end

  def record_current( status )
    MarketReport.first.delete if !MarketReport.first.nil? && status[ 'duration' ] < 1
    
    record = MarketReport.first_or_create
    time_covered = minute_difference_of( DateTime.now.utc, record.created_at )
    
    if status[ 'steady_market?' ] && time_covered > 5
      record.update( reported: true )
         
      cast_report( record, time_covered )
    else
      record.reported ? record.delete : update_report( record, status )
      
      ''
    end
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

  def generate_margins( coin )
    coin = Coin.find_by( coin_id: coin ) if coin.is_a?( String )
    atp = coin.profit_take

    usd_price = coin.usd_trade_price

    return nil if atp.nil? || !usd_price.is_a?( Float )
    
    [ humanize_price( ( 100 + atp ).percent_of( usd_price ).round( count_decimals( usd_price ) ) ),
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

  def selected_for_trade?( coin, index, market_status )
    return false if index == 0

    traj_score = coin[ 'trend_45m' ][ 'trajectory_15m' ]
    
    time_mark = coin[ 'last_trend' ][ 'time_mark' ]

    ( market_status[ 'steady_market?' ] ) && ( coin[ 'trade_grade' ] > 75 ) && ( traj_score >= 2 ) && ( time_mark <= 10 )
  end

  def trend_changes_of( coin, trend = nil )
    case trend
    when '8hr'
      coin[ 'trend_8h' ][ 'changes' ]
    when '45m'
      coin[ 'trend_45m' ][ 'changes' ]
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
