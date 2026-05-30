module Admin
  class StockAdjustmentsController < BaseController
    def new
      @products = Product.active.by_item_number
      @adjustment = { direction: "out", reason: "count" }
    end

    def create
      product = Product.find_by(id: adjustment_params[:product_id])
      if product.nil?
        @products = Product.active.by_item_number
        @adjustment = adjustment_params
        flash.now[:alert] = t("app.errors.product_not_found")
        return render :new, status: :unprocessable_entity
      end

      StockAdjustmentCreator.new(
        user: current_user,
        product: product,
        direction: adjustment_params[:direction],
        quantity: adjustment_params[:quantity],
        reason: adjustment_params[:reason],
        note: adjustment_params[:note]
      ).call

      redirect_to admin_stock_movements_path, notice: t("app.flash.stock_adjusted")
    rescue InventoryService::InsufficientStockError => e
      @products = Product.active.by_item_number
      @adjustment = adjustment_params
      flash.now[:alert] = e.message
      render :new, status: :unprocessable_entity
    rescue StockAdjustmentCreator::Error => e
      @products = Product.active.by_item_number
      @adjustment = adjustment_params
      flash.now[:alert] = e.message
      render :new, status: :unprocessable_entity
    end

    private

    def adjustment_params
      params.require(:stock_adjustment).permit(:product_id, :direction, :quantity, :reason, :note)
    end
  end
end
