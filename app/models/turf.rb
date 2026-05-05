class Turf < ApplicationRecord
  belongs_to :turf_venue
  has_many   :turf_availabilities, dependent: :destroy
  has_many   :bookings, dependent: :destroy
  has_many   :reviews, dependent: :destroy

  validates :name, :surface_type, :pitch_format, :price_per_hour, presence: true
  validates :status, inclusion: { in: %w[active inactive] }
  validates :surface_type, inclusion: { in: %w[artificial natural both] }
  validates :pitch_format, inclusion: { in: ["5-a-side", "7-a-side", "11-a-side"] }
  validates :price_per_hour, numericality: { greater_than: 0 }
  validates :slot_duration_minutes, inclusion: { in: [30, 60, 90, 120] }
  validates :min_booking_minutes, numericality: { greater_than: 0 }
end
