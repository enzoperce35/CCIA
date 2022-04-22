require_relative './unicode_generator.rb'

module HomeHelper
  def score_trade(buy, sell)   #not on service
    ((buy + sell) / 2).round(2)
  end

  def generate_unicode_for(coin)
    if coin['user_price_gain'].between?(-5, 5)
      unicode_for_user_price_status(coin)
    else
      unicode_for_impulsive_move(coin)
    end
  end
end
