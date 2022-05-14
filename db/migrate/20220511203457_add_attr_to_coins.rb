class AddAttrToCoins < ActiveRecord::Migration[6.1]
  def change
    add_column :coins, :observed?, :boolean, default: false
    add_column :coins, :observed_price, :float
    add_column :coins, :on_hold, :float
  end
end
