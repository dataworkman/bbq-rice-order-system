class InventoryService
  class Error < StandardError; end
  class InsufficientStockError < Error; end

  def self.record!(product:, quantity:, movement_type:, user:, reference: nil, note: nil)
    new(
      product: product,
      quantity: quantity,
      movement_type: movement_type,
      user: user,
      reference: reference,
      note: note
    ).record!
  end

  def initialize(product:, quantity:, movement_type:, user:, reference: nil, note: nil)
    @product = product
    @quantity = quantity
    @movement_type = movement_type
    @user = user
    @reference = reference
    @note = note
  end

  def record!
    movement = nil

    ActiveRecord::Base.transaction do
      product = Product.lock.find(@product.id)
      new_balance = product.stock + @quantity

      if new_balance.negative?
        raise InsufficientStockError,
              I18n.t("app.errors.insufficient_stock", name: product.name, stock: product.stock)
      end

      product.update!(stock: new_balance)

      movement = StockMovement.create!(
        product: product,
        user: @user,
        quantity: @quantity,
        movement_type: @movement_type,
        reference: @reference,
        note: @note,
        balance_after: new_balance
      )
    end

    movement
  end
end
