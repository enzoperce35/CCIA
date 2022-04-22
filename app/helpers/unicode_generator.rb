def arrow_down
  "\u2B07".encode('utf-8')
end

def arrow_up
  "\u2B06".encode('utf-8')
end

def warning
  "\u{26A0}".encode('utf-8')
end

def flaming
  "\u{1F525}".encode('utf-8')
end

def unicode_for_impulsive_move(coin)
  coin_price = entry_price_of(coin)

  unicode = coin['user_price_gain'] > 0 ?  flaming : warning
  
  gain = coin['user_price_gain'].round(2).to_s
    
  unicode + gain + '%'
end

def unicode_for_user_price_status(coin)
  coin_price = entry_price_of(coin)

  unicode = coin['user_price_gain'] > 0 ? arrow_up : arrow_down

  gain = coin['user_price_gain'].round(2).to_s
    
  unicode + gain + '%'
end