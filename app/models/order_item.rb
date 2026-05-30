class OrderItem < ApplicationRecord
  belongs_to :order
  belongs_to :product

  validates :quantity, numericality: { greater_than: 0, only_integer: true }
  validates :unit_price, numericality: { greater_than: 0, only_integer: true }

  def subtotal
    quantity * unit_price
  end

  def formatted_subtotal
    ApplicationController.helpers.format_money(subtotal)
  end

  def display_item_number
    item_number.presence || product&.item_number
  end
end
