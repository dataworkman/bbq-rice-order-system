class CartsController < ApplicationController
  before_action :require_owner

  def show
    redirect_to products_path(anchor: "order-summary")
  end

  def add
    @product = find_cart_product
    return unless @product

    @quantity_added = [ params[:quantity].to_i, 1 ].max

    unless @product.orderable?
      return respond_with_flash(alert: t("app.flash.out_of_stock", name: @product.name))
    end

    current_qty = cart_items[@product.id.to_s].to_i
    new_qty = current_qty + @quantity_added

    if new_qty > @product.stock
      return respond_with_flash(alert: t("app.flash.exceeds_stock", name: @product.name, stock: @product.stock, unit: @product.unit))
    end

    cart_items[@product.id.to_s] = new_qty
    load_cart_products

    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: cart_stream(
          product: @product,
          quantity_input: @quantity_added,
          message: t("app.flash.cart_added", name: @product.name, quantity: @quantity_added, unit: @product.unit)
        )
      end
      format.html { redirect_to products_path, notice: t("app.flash.cart_added", name: @product.name, quantity: @quantity_added, unit: @product.unit) }
    end
  end

  def update
    @product = find_cart_product
    return unless @product

    quantity = params[:quantity].to_i

    if quantity <= 0
      cart_items.delete(@product.id.to_s)
      load_cart_products
      return respond_to do |format|
        format.turbo_stream do
          render turbo_stream: cart_stream(
            product: @product,
            message: t("app.flash.cart_item_removed", name: @product.name)
          )
        end
        format.html { redirect_to products_path(anchor: "order-summary"), notice: t("app.flash.cart_item_removed", name: @product.name) }
      end
    end

    if quantity > @product.stock
      return respond_with_flash(alert: t("app.flash.exceeds_stock", name: @product.name, stock: @product.stock, unit: @product.unit))
    end

    cart_items[@product.id.to_s] = quantity
    load_cart_products

    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: cart_stream(
          product: @product,
          quantity_input: quantity,
          message: t("app.flash.cart_updated")
        )
      end
      format.html { redirect_to products_path(anchor: "order-summary"), notice: t("app.flash.cart_updated") }
    end
  end

  def clear
    @cleared_products = Product.where(id: cart_items.keys)
    clear_cart!
    load_cart_products

    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: cart_stream(
          products: @cleared_products,
          message: t("app.flash.cart_cleared")
        )
      end
      format.html { redirect_to products_path, notice: t("app.flash.cart_cleared") }
    end
  end

  private

  def find_cart_product
    product = Product.find_by(id: params[:product_id])
    return product if product

    respond_with_flash(alert: t("app.errors.owner.product_not_found"))
    nil
  end

  def respond_with_flash(alert:)
    respond_to do |format|
      format.turbo_stream { render_friendly_flash(:alert, alert) }
      format.html { redirect_to products_path, alert: alert }
    end
  end

  def cart_stream(product: nil, products: [], quantity_input: 1, message: nil)
    streams = []
    streams << turbo_stream.replace("order-summary", partial: "products/order_summary")
    streams << turbo_stream.replace("nav-my-order", partial: "shared/nav_my_order")

    if message.present?
      streams << turbo_stream.replace(
        "flash-messages",
        partial: "shared/flash_messages",
        locals: { type: :notice, message: message }
      )
    end

    refresh_products = products.presence || [ product ].compact
    refresh_products.each do |p|
      qty = (p.id == product&.id) ? quantity_input : 1
      streams << turbo_stream.replace(
        dom_id(p, :row),
        partial: "products/product_row",
        locals: { product: p, quantity_input: qty }
      )
    end

    streams
  end
end
