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

  def generate_margins( coin )
    coin = Coin.find_by( coin_id: coin ) if coin.is_a?( String )

    trade_price = coin.usd_trade_price
    
    [ humanize_price( 105.percent_of( trade_price ) ), humanize_price( 90.percent_of( trade_price ) ) ]
  end

  def trade_margin_is_below( price_gain )
    !price_gain.between?(-2, 0.1)
  end

  def trade_ready?( user_coin, price_gain)
    is_user_owned?( user_coin ) && trade_margin_is_below( price_gain )
  end

  def find_focus
    user_coins = Coin.where(owned?: true)

    return Coin.first.coin_id if user_coins.count.zero?

    middle_coin = (user_coins.count / 2).to_i

    user_coins[middle_coin].coin_id
  end

  def current_price_of(coin, currency = 'php' )
    case coin
    when Hash
      coin['current_price'].to_f
    else
      market( coin, currency )['current_price'].to_f
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
