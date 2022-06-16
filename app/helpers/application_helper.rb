require 'bigdecimal'

class Numeric
  def percent_of(n)
    self.to_f * n.to_f / 100.0
  end
end

module ApplicationHelper
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

  def generate_margins( coin )
    coin = Coin.find_by( coin_id: coin ) if coin.is_a?( String )

    trade_price = coin.usd_trade_price
    
    [ humanize_price( 105.percent_of( trade_price ).round( count_decimals( trade_price ) ) ),
      humanize_price( 90.percent_of( trade_price ).round( count_decimals( trade_price ) ) ) ]
  end

  def find_focus
    user_coins = Coin.where(owned?: true)

    return Coin.first.coin_id if user_coins.count.zero?

    middle_coin = (user_coins.count / 2).to_i

    user_coins[middle_coin].coin_id
  end

  def price_of( trend, index = nil )
    if index.nil?
      trend[ 1 ]
    else
      trend[ index ][1]
    end
  end

  def value_color( value )
    value < 0 ? 'red' : 'green'
  end
  

  def current_price_of(coin, currency = 'php' )
    case coin
    when String
      market( coin, currency )['current_price'].to_f
    else
      coin['current_price'].to_f
    end
  end

  def low_24h(coin)
    coin['low_24h']
  end
  
  def high_24h(coin)
    coin['high_24h']
  end

  def no_user_coin_yet?
    Coin.where(owned?: true).count.zero?
  end

  def is_user_owned?(coin)
    coin.owned?
  end

  def percentage_between(price_a, price_b)
    ((price_a.to_f / price_b.to_f)  * 100).round(2)
  end

  def assemble(list)
    list.map do |h|
      name = h['name'] + '( ' + h['symbol'] + ' )' + ' ' + h['id']

      [name, h['id']]
    end
  end

  def user(coin)
    coin_id = coin.is_a?(String) ? coin : coin['id']
    
    Coin.find_by(coin_id: coin_id) 
  end

  def market( user_coin, currency = 'php' )
    coin_id = user_coin.is_a?(String) ? user_coin : user_coin.coin_id
    
    client.markets( coin_id, vs_currency: currency ).pop
  end

  def client
    CoingeckoRuby::Client.new
  end
end
