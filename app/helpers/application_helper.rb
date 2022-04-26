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
