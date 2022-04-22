class CreateCoins < ActiveRecord::Migration[6.1]
  def change
    create_table :coins do |t|
      t.string :coin_id
      t.string :status
      t.float :value

      t.timestamps
    end
  end
end
