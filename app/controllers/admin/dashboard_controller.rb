module Admin
  class DashboardController < BaseController
    def index
      @franchise_count = Franchise.count
      @product_count = Product.count
      @pending_orders = Order.pending.recent.limit(10)
      @low_stock_products = Product.low_stock.limit(10)
    end
  end
end
