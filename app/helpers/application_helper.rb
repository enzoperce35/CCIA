module ApplicationHelper
  def scientific_notation?(number)  #inactive
    number.to_s.include?('-')
  end
  
  def humanize_price(number)  #inactive
    if scientific_notation?(number)
      "%.8f" % number
    else
      number
    end
  end

  def current_price_of(coin)
    case coin
    when Hash
      coin['current_price'].to_f
    else
      market( coin )['current_price'].to_f
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

  def market(user_coin)
    coin_id = user_coin.is_a?(String) ? user_coin : user_coin.coin_id
    
    client.markets( coin_id, vs_currency: 'php' ).pop
  end

  def client
    CoingeckoRuby::Client.new
  end
end
