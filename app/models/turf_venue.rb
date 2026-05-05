class TurfVenue < ApplicationRecord
  belongs_to :user
  has_one    :amenity, dependent: :destroy
  has_many   :turfs, dependent: :destroy
  has_many_attached :images

  validates :name, :full_address, :county, :latitude, :longitude, :contact_phone, presence: true
  validates :status, inclusion: { in: %w[draft active inactive] }

  validate :validate_attached_images

  private

  def validate_attached_images
    return unless images.attached?

    images.each do |image|
      if image.byte_size.to_i > 10.megabytes
        errors.add(:images, "each image must be less than 10MB")
        break
      end

      allowed_types = %w[image/jpeg image/png image/webp]
      unless allowed_types.include?(image.content_type.to_s)
        errors.add(:images, "each image must be JPEG, PNG, or WEBP format")
        break
      end
    end
  end
end
