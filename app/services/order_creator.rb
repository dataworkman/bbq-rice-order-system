class OrderCreator
  class Error < StandardError; end
  class InsufficientStockError < Error; end
  class EmptyCartError < Error; end

  def initialize(user:, cart_items:)
    @user = user
    @cart_items = cart_items
  end

  def call
    raise EmptyCartError, I18n.t("app.errors.empty_cart") if @cart_items.blank?

    order = nil
    line_items = []

    ActiveRecord::Base.transaction do
      products = Product.lock.where(id: @cart_items.keys).index_by(&:id)
      total = 0

      @cart_items.each do |product_id, quantity|
        product = products[product_id.to_i]
        qty = quantity.to_i

        raise Error, I18n.t("app.errors.product_not_found") if product.nil?
        if qty > product.stock
          raise InsufficientStockError, I18n.t("app.errors.insufficient_stock", name: product.name, stock: product.stock)
        end
        unless product.orderable?
          raise Error, I18n.t("app.errors.not_orderable", name: product.name)
        end

        line_items << { product: product, quantity: qty, unit_price: product.unit_price }
        total += product.unit_price * qty
      end

      order = Order.create!(
        franchise: @user.franchise,
        user: @user,
        status: :pending,
        total_amount: total
      )

      line_items.each do |item|
        order.order_items.create!(
          product: item[:product],
          item_number: item[:product].item_number,
          quantity: item[:quantity],
          unit_price: item[:unit_price]
        )
        InventoryService.record!(
          product: item[:product],
          quantity: -item[:quantity],
          movement_type: :order_out,
          user: @user,
          reference: order
        )
      end
    end

    OrderMailer.with(locale: I18n.locale).order_confirmation(order).deliver_later
    order
  rescue InventoryService::InsufficientStockError => e
    raise InsufficientStockError, e.message
  end
end
