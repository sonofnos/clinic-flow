class Patient < ApplicationRecord
  has_many :appointments, dependent: :restrict_with_error

  validates :name, presence: true
  validates :date_of_birth, presence: true
  validates :email, format: { with: URI::MailTo::EMAIL_REGEXP }, allow_blank: true
end
