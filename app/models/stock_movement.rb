class StockMovement < ApplicationRecord
  belongs_to :product
  belongs_to :user
  belongs_to :reference, polymorphic: true, optional: true

  enum :movement_type, {
    inbound: 0,
    adjustment_in: 1,
    adjustment_out: 2,
    order_out: 3,
    order_cancel: 4
  }

  validates :quantity, presence: true, numericality: { only_integer: true, other_than: 0 }
  validates :balance_after, numericality: { greater_than_or_equal_to: 0, only_integer: true }

  scope :recent, -> { order(created_at: :desc) }

  def movement_type_label
    I18n.t("app.inventory.movement_types.#{movement_type}")
  end

  def signed_quantity_label
    prefix = quantity.positive? ? "+" : ""
    "#{prefix}#{quantity}#{product.unit}"
  end
end
