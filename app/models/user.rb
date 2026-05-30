class User < ApplicationRecord
  belongs_to :franchise, optional: true
  has_many :orders, dependent: :restrict_with_error

  has_secure_password

  enum :role, { owner: 0, admin: 1 }

  validates :email, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :franchise, presence: true, if: :owner?
end
