module CoinsHelper
 
  def sum_price_changes(prices, x = 0)
    prices.each { |p| x += p[1]}

    x
  end

  def analyze_change_in( trends, arr = [] )
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
  
  def insert_price_trends_of(coin)
    prices = client.minutely_historical_price(coin['id'])
    
    trends = get_last_ten_changes_of(prices)
      
    coin.store('trend', analyze_change_in( trends ) )
   
    coin
  end

  def price_gain_of(coin)
    percentage_between( current_price_of(coin), user( coin ).trade_price ) - 100
  end

  def insert_price_gain_of(coin)
    user_coin = user( coin )
    
    if user_coin.trade_price.nil?
      coin.store('price_gain', 'N/A' )
    else
      coin.store('price_gain', price_gain_of( coin ) )
    end
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
  
  def insert_extra_values_from(coins)
    coins = client.markets( coins, vs_currency: 'php' )
    
    coins.map do |coin|
      insert_current_vs_24h_prices_of(coin)
      
      insert_price_gain_of(coin)

      insert_price_trends_of(coin)
    end
  end
end
