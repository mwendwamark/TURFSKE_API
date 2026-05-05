class TurfAvailability < ApplicationRecord
  belongs_to :turf

  validates :day_of_week, inclusion: { in: 0..6 }
  validates :day_of_week, uniqueness: { scope: :turf_id }
  validates :open_time, :close_time, presence: true, if: :is_open?
end
