module CoinsHelper

  def sum_price_changes(prices, x = 0)
    prices.each { |p| x += p[1]}

    x
  end

  def analyze_change_in(coin, trends, arr = [])
    trends.each_with_index do |trend, index|
      next if index == 0
    
      price_a = trends[index-1]
    
      price_b = trend

      change_indicator = price_a <= price_b ? 'green' : 'red'
    
      arr << [ change_indicator, (percentage_between( price_b, price_a ) - 100).abs ]
    end
    arr
  end

  def get_last_ten_changes_of(prices, arr = [])
    prices = prices['prices'][-11..-1]
    
    prices.each { |_, price|  arr << price } 
      
    arr
  end
  
  def insert_price_trends(coins)
    coins.each do |coin|
      prices = client.minutely_historical_price(coin['id'])
    
      trends = get_last_ten_changes_of(prices)
      
      coin.store('trend', analyze_change_in(coin, trends) )
    end
    coins
  end

  def switch_status( coin )
    coin = Coin.find_by( coin_id: coin )
    
    if user_coin_has_entry?( market( coin ) ) 
      coin.update( status: 'observe', value: nil )
    else
      coin.update( status: 'buy', value: current_price_of( market( coin ) ) )
    end
  end
  
  def perform_trade( buy, sell )
    buy = Coin.find_by( coin_id: buy )
    sell = Coin.find_by( coin_id: sell )
      
    buy.update( status: 'observe', value: nil )
    sell.update( status: 'buy', value: current_price_of( market( sell ) ) )
  end

  def arrange( coins, buy = [], observe = [] )
    coins.each do |coin|
      user_coin_has_entry?( coin ) ? buy.push( coin ) : observe.push( coin )
    end
  
    buy = buy.sort_by { |k| k['user_price_gain'] }
    observe = observe.sort_by { |k| k['vs_24h'] }
      
    [buy, observe]
  end

  def coin_reaches_lose_margin?(coin)
    user_coin_has_entry?(coin) &&
    coin['user_price_gain'] < -5
  end
  
  def insert_user_price_of(coin)
    key = 'entry_price' 
  
    val = user(coin).value
  
    insert_pair(coin, 'current_price', {key=>val}, :before)
  end
  
  def user_coin_has_entry?(coin)
    user(coin).status == 'buy' &&
    user(coin).value.present?
  end
  
  def entry_price_of(coin)
    user(coin).value
  end

  def low_24h(coin)
    coin['low_24h']
  end
  
  def high_24h(coin)
    coin['high_24h']
  end

  def current_price_of(coin)
    coin['current_price']
  end

  def insert_pair(h, key, pair, proximity=:before)
    h.to_a.insert(h.keys.index(key) + (proximity==:after ? 1 : 0), pair.first).to_h
  end
  
  def insert_user_gain_of(coin)
    coin.store( 'user_price_gain',
                 percentage_between( current_price_of(coin),
                 entry_price_of(coin) ) - 100 )
  end
  
  def get_difference( high, low, current )
    range = high - low
  
    current -= low
  
    percentage_between(current, range)
  end
  
  def insert_current_vs_24h_prices_of(coin)
    difference = get_difference( high_24h(coin), low_24h(coin), current_price_of(coin) )
  
    coin.store( "vs_24h", difference )
  end  

  def insert_values_from(coin)
    coin = market(coin)
  
    insert_current_vs_24h_prices_of(coin)
      
    insert_user_gain_of(coin) if user_coin_has_entry?(coin)
  
    insert_user_price_of(coin)
  end
  
  def insert_extra_values_from(user_coins, arr = [])
    user_coins.each do |coin|
      coin = insert_values_from(coin)
      arr << coin
    end
    arr
  end
end
