module CoinModules
  module ViewCoins
    def fetch_user_coins( view, trade_coin = nil )
      case view
      when 'active_coins_view'
        Coin.active.pluck( 'coin_id' ).join(', ')
      when 'inactive_coins_view'
        Coin.inactive.pluck( 'coin_id' ).join(', ')
      when 'trade_view'
        trade_coin = helpers.user( @trade_coin )
        
        if trade_coin.coin_type == 'stablecoin'
          Coin.idle.where.not( coin_type: 'stablecoin').pluck( 'coin_id' ).push( @trade_coin ).join(', ')
        else
          Coin.idle.pluck( 'coin_id' ).push( @trade_coin ).join(', ')
        end
      else
        ( Coin.owned + Coin.observed ).pluck( 'coin_id' ).join(', ')
      end
    end
    
    def fetch_user_view( actives, inactives, trade )
      if actives
        'active_coins_view'
      elsif inactives
        'inactive_coins_view'
      elsif trade.present?
        'trade_view'
      else
        'observe_view'
      end
    end
  end
end
