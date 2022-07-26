class AddMinmaxToCoin < ActiveRecord::Migration[6.1]
  def change
    add_column :coins, :min_max, :text, array: true, default: []
  end
end
