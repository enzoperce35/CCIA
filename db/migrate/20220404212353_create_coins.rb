class CreateCoins < ActiveRecord::Migration[6.1]
  def change
    create_table :coins do |t|
      t.string :coin_id
      t.float :binance_min
      t.float :buy
      t.float :sell
      t.float :profit, default: 0

      t.timestamps
    end
  end
end
