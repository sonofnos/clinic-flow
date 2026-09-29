class User < ApplicationRecord
  has_secure_password

  enum :role, { admin: 0, staff: 1, provider: 2 }, default: :staff

  has_one :provider_profile, class_name: "Provider", dependent: :destroy

  validates :email, presence: true, uniqueness: { case_sensitive: false },
                     format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :name, presence: true

  before_save { self.email = email.downcase.strip }
end
