class CreateMarketReports < ActiveRecord::Migration[6.1]
  def change
    create_table :market_reports do |t|
      t.integer :bullish, default: 0
      t.integer :bearish, default: 0
      t.boolean :reported, default: false

      t.timestamps
    end
  end
end
