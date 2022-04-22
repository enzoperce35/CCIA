def set_initial_coin_status(coin, coin_infos, index)
  current_price = coin_infos['current_price']
  
  if index.odd?
    coin.update(status: 'buy', value: current_price)
  else
    coin.update(status: 'observe')
  end
end

def set_seeded_coin_status
  client = CoingeckoRuby::Client.new
  
  Coin.all.each_with_index do |coin, index|
    coin_infos = client.markets(coin.coin_id, vs_currency: 'php').pop

    set_initial_coin_status(coin, coin_infos, index)
  end
end
