class AddProfitTakeToCoins < ActiveRecord::Migration[6.1]
  def change
    add_column :coins, :profit_take, :float
  end
end
