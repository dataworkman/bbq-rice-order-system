class Order < ApplicationRecord
  belongs_to :franchise
  belongs_to :user
  has_many :order_items, dependent: :destroy
  has_many :products, through: :order_items

  enum :status, {
    pending: 0,
    confirmed: 1,
    shipped: 2,
    delivered: 3,
    cancelled: 4
  }

  validates :total_amount, numericality: { greater_than: 0, only_integer: true }, unless: :cancelled?
  validate :franchise_matches_user, on: :create

  scope :recent, -> { order(created_at: :desc) }

  def cancellable?
    pending? || confirmed?
  end

  def formatted_total
    ApplicationController.helpers.format_money(total_amount)
  end

  def status_label
    I18n.t("order.status.#{status}")
  end

  private

  def franchise_matches_user
    return if user.blank? || franchise.blank?
    return if user.admin? || user.franchise_id == franchise_id

    errors.add(:franchise, "는 주문자의 가맹점과 일치해야 합니다")
  end
end
