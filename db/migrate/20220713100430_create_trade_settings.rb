class CreateTradeSettings < ActiveRecord::Migration[6.1]
  def change
    create_table :trade_settings do |t|
      t.float :time_mark
      t.float :vs_24h
      t.float :trade_grade
      t.float :profit_take
      t.float :uptrend_anomaly
      t.boolean :uptrending
      t.float :pump_30m
      t.float :dump_8h

      t.timestamps
    end
  end
end
