class Booking < ApplicationRecord
  belongs_to :turf
  belongs_to :player, class_name: "User", foreign_key: :player_id
  has_one    :review
  has_one    :turf_venue, through: :turf
end
