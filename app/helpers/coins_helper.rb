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

  def user_coin_has_entry?(coin)
    user(coin).status == 'buy' &&
    user(coin).value.present?
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
  
  def get_difference( high, low, current )
    range = high - low
  
    current -= low
  
    percentage_between(current, range)
  end
  
  def insert_current_vs_24h_prices_of(coin)
    difference = get_difference( high_24h(coin), low_24h(coin), current_price_of(coin) )
  
    coin.store( "vs_24h", difference )

    coin
  end  
  
  def insert_extra_values_from(user_coins, arr = [])
    user_coins.each do |coin|
      coin = market(coin)
      
      coin = insert_current_vs_24h_prices_of(coin)
      
      arr << coin
    end
    arr
  end
end
