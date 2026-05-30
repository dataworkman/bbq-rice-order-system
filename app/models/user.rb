class User < ApplicationRecord
  belongs_to :franchise, optional: true
  has_many :orders, dependent: :restrict_with_error
  has_many :stock_movements, dependent: :restrict_with_error
  has_many :stock_receipts, dependent: :restrict_with_error

  has_secure_password

  enum :role, { owner: 0, admin: 1 }

  generates_token_for :password_reset, expires_in: 2.hours do
    password_salt&.last(10)
  end

  validates :email, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :franchise, presence: true, if: :owner?
end
