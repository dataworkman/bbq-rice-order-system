module Admin
  class InventoryController < BaseController
    def show
      @low_stock_products = Product.low_stock.limit(10)
      @out_of_stock_count = Product.active.where(stock: 0).count
      @recent_movements = StockMovement.includes(:product, :user).recent.limit(10)
      @recent_receipts = StockReceipt.includes(:user).order(received_on: :desc, created_at: :desc).limit(5)
    end
  end
end
