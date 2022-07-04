class CreateMarketRuns < ActiveRecord::Migration[6.1]
  def change
    create_table :market_runs do |t|
      t.string :name
      t.integer :warmth, default: 0
      t.integer :runs, default: 0
      t.datetime :started
      t.text :movement, array: true, default: []

      t.timestamps
    end
  end
end
