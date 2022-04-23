class Coin < ApplicationRecord
  validates_presence_of :coin_id, on: [:create, :edit]
  validates_uniqueness_of :coin_id, on: [:create, :edit]

  before_save :check_coin_legitimacy

  private

  def check_coin_legitimacy
    coin = CoingeckoRuby::Client.new.markets(coin_id, vs_currency: 'php').pop
    required = ['id', 'symbol', 'name', 'image', 'current_price', 'high_24h', 'low_24h']

    required.each do |r|
      throw(:abort) if coin[r].nil?
    end
  end
end
