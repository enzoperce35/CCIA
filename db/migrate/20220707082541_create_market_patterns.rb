class CreateMarketPatterns < ActiveRecord::Migration[6.1]
  def change
    create_table :market_patterns do |t|
      t.text :pattern, array: true, default: []

      t.timestamps
    end
  end
end
