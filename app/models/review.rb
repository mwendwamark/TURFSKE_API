class Review < ApplicationRecord
  belongs_to :turf
  belongs_to :booking
  belongs_to :player, class_name: "User", foreign_key: :player_id

  validates :rating, inclusion: { in: 1..5 }
  validates :player_id, uniqueness: { scope: :booking_id }
end
