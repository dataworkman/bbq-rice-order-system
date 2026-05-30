class StockReceiptLine < ApplicationRecord
  belongs_to :stock_receipt
  belongs_to :product

  validates :quantity, numericality: { only_integer: true, greater_than: 0 }
end
