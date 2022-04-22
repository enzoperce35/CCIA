require_relative './extra_values.rb'

module CoinsHelper

  def arrange(coins, buy = [], observe = [])
    coins.each do |coin|
      user_coin_has_entry?(coin) ? buy.push(coin) : observe.push(coin)
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

  def is_observing?(coin)
    coin.status == 'observe'
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
    
    arrange(arr)
  end
end
