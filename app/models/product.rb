class Product < ApplicationRecord
  has_many :order_items, dependent: :restrict_with_error

  validates :name, :category, :unit, :item_number, presence: true
  validates :item_number, uniqueness: { case_sensitive: false }
  validates :item_number, format: { with: /\A[A-Z0-9-]+\z/i }
  validates :unit_price, numericality: { greater_than: 0, only_integer: true }
  validates :stock, numericality: { greater_than_or_equal_to: 0, only_integer: true }

  scope :active, -> { where(active: true) }
  scope :orderable, -> { active.where("stock > 0") }
  scope :by_item_number, -> { order(:item_number) }

  def unit_price_dollars
    unit_price / 100.0 if unit_price
  end

  def unit_price_dollars=(value)
    self.unit_price = (value.to_f * 100).round if value.present?
  end

  def orderable?
    active? && stock.positive?
  end

  def formatted_price
    ApplicationController.helpers.format_money(unit_price)
  end
end
