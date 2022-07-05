puts 'seeding...'

  # coingecko cloudfare limits seeding to 27, so at least 25 of these coins is chosen to be active
  Coin.create(coin_id: 'tether', coin_type: 'stablecoin')
  Coin.create(coin_id: 'binance-usd', coin_type: 'stablecoin')
  Coin.create(coin_id: 'usd-coin', coin_type: 'stablecoin')
  Coin.create(coin_id: 'dai', coin_type: 'stablecoin')
  Coin.create(coin_id: 'yield-guild-games', coin_type: 'shitcoin')
  Coin.create(coin_id: 'mines-of-dalarnia', coin_type: 'shitcoin')
  Coin.create(coin_id: 'ripple', coin_type: 'altcoin')
  Coin.create(coin_id: 'solana', coin_type: 'altcoin')
  Coin.create(coin_id: 'cardano', coin_type: 'altcoin')
  Coin.create(coin_id: 'dogecoin', coin_type: 'altcoin')
  Coin.create(coin_id: 'matic-network', coin_type: 'altcoin')
  Coin.create(coin_id: 'polkadot', coin_type: 'altcoin')
  Coin.create(coin_id: 'binancecoin', coin_type: 'altcoin')
  Coin.create(coin_id: 'gala', coin_type: 'altcoin')
  Coin.create(coin_id: 'near', coin_type: 'altcoin')
  Coin.create(coin_id: 'chainlink', coin_type: 'altcoin')
  Coin.create(coin_id: 'bella-protocol', coin_type: 'shitcoin')
  Coin.create(coin_id: 'dodo', coin_type: 'altcoin')
  Coin.create(coin_id: 'litecoin', coin_type: 'altcoin')
  Coin.create(coin_id: 'ellipsis-x', coin_type: 'altcoin')
  Coin.create(coin_id: 'monero', coin_type: 'altcoin')
  Coin.create(coin_id: 'stellar', coin_type: 'altcoin')
  Coin.create(coin_id: 'smooth-love-potion', coin_type: 'shitcoin')
  Coin.create(coin_id: 'sushi', coin_type: 'shitcoin')
  Coin.create(coin_id: 'shiba-inu', coin_type: 'shitcoin')
  

  Coin.create(coin_id: 'bitcoin', coin_type: 'altcoin', is_active: false )
  Coin.create(coin_id: 'ethereum', coin_type: 'altcoin', is_active: false )
  Coin.create(coin_id: 'terra-luna', coin_type: 'altcoin', is_active: false )
  Coin.create(coin_id: 'jasmycoin', coin_type: 'shitcoin', is_active: false )
  Coin.create(coin_id: 'moonbeam', coin_type: 'shitcoin', is_active: false )
  Coin.create(coin_id: 'uniswap', coin_type: 'altcoin', is_active: false )
  Coin.create(coin_id: 'terrausd', coin_type: 'altcoin', is_active: false )

  MarketRun.create( name: 'bullish' )
  MarketRun.create( name: 'bearish' )
  MarketRun.create( name: 'normal' )

  coin_ids = Coin.where( is_active: true ).pluck( 'coin_id' ).join(', ')
  coins = CoingeckoRuby::Client.new.markets( coin_ids, vs_currency: 'php' )

  coins.each do | coin |
    user_coin = Coin.find_by( coin_id: coin[ 'id' ] )
    user_coin.update( coin_name: coin[ 'name' ], coin_sym: coin[ 'symbol' ],
                      long_gain: coin[ 'current_price' ], short_gain: coin[ 'current_price' ] )
  end
  
puts 'seeding done'
