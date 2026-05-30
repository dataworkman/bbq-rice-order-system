module Admin
  class StockMovementsController < BaseController
    def index
      @movements = StockMovement.includes(:product, :user).recent
      @movements = @movements.where(product_id: params[:product_id]) if params[:product_id].present?
      @movements = @movements.where(movement_type: params[:movement_type]) if StockMovement.movement_types.key?(params[:movement_type])
      @movements = @movements.limit(100)
      @products = Product.by_item_number
    end
  end
end
