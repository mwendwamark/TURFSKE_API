class Payment < ApplicationRecord
  belongs_to :turf_venue, optional: true
  belongs_to :user

  validates :payment_type, :amount_kobo, :currency, :paystack_reference, :status, presence: true
  validates :paystack_reference, uniqueness: true

  scope :listing_fee, -> { where(payment_type: "listing_fee") }

  def successful?
    status == "success"
  end
end
