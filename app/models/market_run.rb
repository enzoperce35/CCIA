class MarketRun < ApplicationRecord
  scope :warm, -> { where( "warmth > ?", 0 ) }
end
