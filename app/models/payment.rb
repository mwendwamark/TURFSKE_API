class Payment < ApplicationRecord
  belongs_to :turf_venue
  belongs_to :user
end
