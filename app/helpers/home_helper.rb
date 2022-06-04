module HomeHelper
  def filter_trade( coins, trade_coin )
    trade_coin = coins.find { |c| c['id'] == trade_coin }

    coins -= [ trade_coin ]
    
    coins = coins.sort_by { |k| k['vs_24h'] }.slice(0, 10)

    coins.unshift( trade_coin )
  end
end
