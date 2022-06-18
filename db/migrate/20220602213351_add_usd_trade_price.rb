class AddUsdTradePrice < ActiveRecord::Migration[6.1]
  def change
    add_column :coins, :usd_trade_price, :float
    add_column :coins, :coin_type, :string, default: 'altcoin'
    add_column :coins, :fuse_count, :integer, default: 0
  end
end
