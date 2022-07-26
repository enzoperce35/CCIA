# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2022_07_25_111655) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "coins", force: :cascade do |t|
    t.string "coin_id"
    t.string "coin_name"
    t.string "coin_sym"
    t.string "coin_type", default: "altcoin"
    t.boolean "is_active", default: true, null: false
    t.boolean "is_observed", default: false, null: false
    t.float "long_gain"
    t.float "short_gain"
    t.float "holdings"
    t.float "usd_trade_price"
    t.integer "fuse_count", default: 0
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.float "profit_take"
    t.text "min_max", default: [], array: true
  end

  create_table "market_patterns", force: :cascade do |t|
    t.text "pattern", default: [], array: true
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "market_runs", force: :cascade do |t|
    t.string "name"
    t.integer "warmth", default: 0
    t.integer "runs", default: 0
    t.datetime "started"
    t.text "movement", default: [], array: true
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "trade_settings", force: :cascade do |t|
    t.float "time_mark"
    t.float "vs_24h"
    t.float "trade_grade"
    t.float "profit_take"
    t.float "uptrend_anomaly"
    t.boolean "uptrending"
    t.float "pump_30m"
    t.float "dump_8h"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "users", force: :cascade do |t|
    t.string "username", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["username"], name: "index_users_on_username", unique: true
  end

end
