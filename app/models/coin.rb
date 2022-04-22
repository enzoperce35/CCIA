class Coin < ApplicationRecord
  validates_presence_of :coin_id, on: [:create, :edit]
  validates_uniqueness_of :coin_id, on: [:create, :edit]

  scope :buyers, -> { where( exit: nil ) }
  scope :sellers, -> { where( entry: nil ) }
end
