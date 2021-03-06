class Coin < ApplicationRecord
  validates_presence_of :coin_id, on: [ :create, :edit ]
  validates_uniqueness_of :coin_id, on: [ :create, :edit ]
  validates_presence_of :coin_type, on: [ :create, :edit ]

  before_save :check_coin_legitimacy

  scope :owned, -> { where( is_active: true ).where( 'fuse_count > ?', 0 ) }
  scope :idle, -> { where( is_active: true ).where( 'fuse_count <= ?', 0 ) }
  scope :observed, -> { where( is_active: true, is_observed: true ) }
  scope :active, -> { where( is_active: true ) }
  scope :inactive, -> { where( is_active: false ) }

  private

  def check_coin_legitimacy
    coin = CoingeckoRuby::Client.new.markets( coin_id, vs_currency: 'php' ).pop
    
    required = ['id', 'symbol', 'name', 'image', 'current_price', 'high_24h', 'low_24h', 'market_cap_change_percentage_24h', 'last_updated' ]

    required.each do | r |
      throw( :abort ) if coin[ r ].nil?
    end
  end
end
