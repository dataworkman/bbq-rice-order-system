class Franchise < ApplicationRecord
  has_many :users, dependent: :destroy
  has_one :owner, -> { where(role: :owner) }, class_name: "User", inverse_of: :franchise
  has_many :orders, dependent: :restrict_with_error

  validates :name, :address, :owner_email, presence: true
  validates :owner_email, format: { with: URI::MailTo::EMAIL_REGEXP }

  after_update :sync_owner_email, if: :saved_change_to_owner_email?

  private

  def sync_owner_email
    owner&.update!(email: owner_email)
  end
end
