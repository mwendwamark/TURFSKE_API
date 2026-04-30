class User < ApplicationRecord
  include Devise::JWT::RevocationStrategies::JTIMatcher

  devise :database_authenticatable,
         :registerable,
         :recoverable,
         :rememberable,
         :validatable,
         :confirmable,
         :jwt_authenticatable,
         jwt_revocation_strategy: self

  # Validations
  validates :first_name, presence: true
  validates :last_name, presence: true
  validates :phone_number, format: { with: /\A\+?\d{10,15}\z/ }, allow_blank: true, uniqueness: { allow_nil: true }
  validate :single_valid_role

  # Virtual login attribute
  attr_writer :login

  def login
    @login || email || phone_number
  end

  # Helper methods for roles
  def player?
    Array(roles).include?("player")
  end

  def manager?
    Array(roles).include?("manager")
  end

  # JWT revocation check
  def jwt_revoked?(payload, user)
    payload["jti"] != user.jti
  end

  # Generate JTI before creating user
  before_validation :normalize_contact_fields
  before_create :generate_jti
  before_update :refresh_jti_for_password_change, if: :will_save_change_to_encrypted_password?

  # Allow login by email or phone_number
  def self.find_for_database_authentication(warden_conditions)
    conditions = warden_conditions.dup
    if (login = conditions.delete(:login))
      where(conditions.to_h).where([
        "lower(email) = :value OR phone_number = :raw",
        { value: login.downcase, raw: login },
      ]).first
    else
      where(conditions.to_h).first
    end
  end

  # Include id and roles in JWT payload
  def jwt_payload
    { "sub" => id.to_s, "jti" => jti, "roles" => Array(roles) }
  end

  private

  def generate_jti
    self.jti ||= SecureRandom.uuid
  end

  def normalize_contact_fields
    self.email = email.to_s.strip.downcase
    self.phone_number = phone_number.to_s.gsub(/\s+/, "")
  end

  def refresh_jti_for_password_change
    self.jti = SecureRandom.uuid
  end

  def single_valid_role
    allowed = %w[player manager]
    current_roles = Array(roles).reject(&:blank?)
    if current_roles.size != 1
      errors.add(:roles, "must contain exactly one role")
    elsif !allowed.include?(current_roles.first)
      errors.add(:roles, "is invalid")
    end
  end
end
