class Provider < ApplicationRecord
  belongs_to :user
  has_many :appointments, dependent: :restrict_with_error

  validates :specialty, presence: true
  validate :user_must_have_provider_role

  private

  def user_must_have_provider_role
    errors.add(:user, "must have the provider role") if user && !user.provider?
  end
end
