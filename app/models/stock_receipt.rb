class StockReceipt < ApplicationRecord
  belongs_to :user
  has_many :stock_receipt_lines, dependent: :destroy
  has_many :products, through: :stock_receipt_lines
  has_many :stock_movements, as: :reference, dependent: :nullify

  validates :received_on, presence: true

  def total_quantity
    stock_receipt_lines.sum(:quantity)
  end
end
