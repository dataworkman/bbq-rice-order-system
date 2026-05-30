class Franchise < ApplicationRecord
  has_many :users, dependent: :destroy
  has_many :orders, dependent: :restrict_with_error

  validates :name, :address, :owner_email, presence: true
  validates :owner_email, format: { with: URI::MailTo::EMAIL_REGEXP }
end
