module Admin
  class StockReceiptsController < BaseController
    def index
      @stock_receipts = StockReceipt.includes(:user, :stock_receipt_lines).order(received_on: :desc, created_at: :desc)
    end

    def show
      @stock_receipt = StockReceipt.includes(stock_receipt_lines: :product).find_by(id: params[:id])
      redirect_to admin_stock_receipts_path, alert: t("app.errors.owner.not_found") if @stock_receipt.nil?
    end

    def new
      @products = Product.active.by_item_number
      @line_count = 5
    end

    def create
      StockReceiptCreator.new(
        user: current_user,
        received_on: receipt_params[:received_on],
        supplier: receipt_params[:supplier],
        note: receipt_params[:note],
        lines: line_params
      ).call

      redirect_to admin_stock_receipts_path, notice: t("app.flash.stock_receipt_created")
    rescue StockReceiptCreator::Error => e
      @products = Product.active.by_item_number
      @line_count = 5
      flash.now[:alert] = e.message
      render :new, status: :unprocessable_entity
    end

    private

    def receipt_params
      params.require(:stock_receipt).permit(:received_on, :supplier, :note)
    end

    def line_params
      Array(params[:lines]).map do |line|
        line.permit(:product_id, :quantity).to_h.symbolize_keys
      end
    end
  end
end
