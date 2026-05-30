class OrdersController < ApplicationController
  before_action :require_owner
  before_action :set_order, only: %i[show destroy]

  def index
    @orders = current_user.franchise.orders.recent.includes(:order_items)
  end

  def show
  end

  def create
    order = OrderCreator.new(user: current_user, cart_items: cart_items).call
    clear_cart!
    redirect_to order_path(order), notice: t("app.flash.order_placed")
  rescue OrderCreator::InsufficientStockError, OrderCreator::EmptyCartError, OrderCreator::Error => e
    redirect_to products_path(anchor: "order-summary"), alert: e.message
  end

  def destroy
    unless @order.cancellable?
      redirect_to order_path(@order), alert: t("app.flash.order_not_cancellable")
      return
    end

    ActiveRecord::Base.transaction do
      @order.order_items.each do |item|
        item.product.increment!(:stock, item.quantity)
      end
      @order.update!(status: :cancelled)
    end

    redirect_to orders_path, notice: t("app.flash.order_cancelled", id: @order.id)
  end

  private

  def set_order
    @order = current_user.franchise.orders.find(params[:id])
  end
end
