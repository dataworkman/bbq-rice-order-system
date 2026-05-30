module Admin
  class OrdersController < BaseController
    before_action :set_order, only: %i[show update]

    def index
      @orders = Order.recent.includes(:franchise, :user)
      @orders = @orders.where(status: params[:status]) if Order.statuses.key?(params[:status])
    end

    def show
    end

    def update
      new_status = params[:status]
      unless Order.statuses.key?(new_status)
        redirect_to admin_order_path(@order), alert: t("app.flash.invalid_status")
        return
      end

      if @order.cancelled?
        redirect_to admin_order_path(@order), alert: t("app.flash.cancelled_order_locked")
        return
      end

      @order.update!(status: new_status)
      redirect_to admin_order_path(@order), notice: t("app.flash.order_status_changed", status: @order.status_label)
    end

    private

    def set_order
      @order = Order.find(params[:id])
    end
  end
end
