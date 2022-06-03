class AddUsdTradePrice < ActiveRecord::Migration[6.1]
  def change
    add_column :coins, :usd_trade_price, :float
  end
end
