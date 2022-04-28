class CreateCoins < ActiveRecord::Migration[6.1]
  def change
    create_table :coins do |t|
      t.string :coin_id
      t.boolean :owned?, default: false
      t.float :trade_price

      t.timestamps
    end
  end
end
