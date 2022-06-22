class CreateCoins < ActiveRecord::Migration[6.1]
  def change
    create_table :coins do |t|
      t.string :coin_id
      t.string :coin_name
      t.string :coin_sym
      t.string :coin_type, default: 'altcoin'
      t.boolean :is_observed, null: false, default: false
      t.float :long_gain
      t.float :short_gain
      t.float :holdings
      t.float :usd_trade_price
      t.integer :fuse_count, default: 0

      t.timestamps
    end
  end
end
