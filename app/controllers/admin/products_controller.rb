module Admin
  class ProductsController < BaseController
    before_action :set_product, only: %i[edit update destroy]

    def index
      @products = Product.by_item_number
    end

    def new
      @product = Product.new(stock: 0)
    end

    def create
      @product = Product.new(product_params.merge(stock: 0))
      initial_stock = initial_stock_param

      if @product.save
        record_initial_stock(@product, initial_stock)
        redirect_to admin_products_path, notice: t("app.flash.product_created")
      else
        render :new, status: :unprocessable_entity
      end
    end

    def edit
      @recent_movements = @product.stock_movements.recent.limit(5)
    end

    def update
      if @product.update(product_params)
        redirect_to admin_products_path, notice: t("app.flash.product_updated")
      else
        @recent_movements = @product.stock_movements.recent.limit(5)
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      if @product.destroy
        redirect_to admin_products_path, notice: t("app.flash.product_deleted")
      else
        redirect_to admin_products_path, alert: t("app.flash.product_delete_failed")
      end
    end

    private

    def set_product
      @product = Product.find_by(id: params[:id])
      redirect_to admin_products_path, alert: t("app.errors.owner.not_found") if @product.nil?
    end

    def product_params
      params.require(:product).permit(:item_number, :name, :category, :unit_price_dollars, :unit, :active, :reorder_point)
    end

    def initial_stock_param
      params.dig(:product, :initial_stock).to_i
    end

    def record_initial_stock(product, quantity)
      return unless quantity.positive?

      InventoryService.record!(
        product: product,
        quantity: quantity,
        movement_type: :adjustment_in,
        user: current_user,
        note: I18n.t("app.inventory.initial_stock_note")
      )
    end
  end
end
