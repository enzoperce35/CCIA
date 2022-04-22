require_relative './application_helper.rb'

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
