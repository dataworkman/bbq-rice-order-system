module Admin
  class ProductsController < BaseController
    before_action :set_product, only: %i[edit update destroy]

    def index
      @products = Product.by_item_number
    end

    def new
      @product = Product.new
    end

    def create
      @product = Product.new(product_params)
      if @product.save
        redirect_to admin_products_path, notice: t("app.flash.product_created")
      else
        render :new, status: :unprocessable_entity
      end
    end

    def edit
    end

    def update
      if @product.update(product_params)
        redirect_to admin_products_path, notice: t("app.flash.product_updated")
      else
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
      params.require(:product).permit(:item_number, :name, :category, :unit_price_dollars, :stock, :unit, :active)
    end
  end
end
