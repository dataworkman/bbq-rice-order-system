class StockAdjustmentCreator
  class Error < StandardError; end

  ADJUSTMENT_REASONS = %w[count damage loss correction other].freeze

  def initialize(user:, product:, direction:, quantity:, reason:, note: nil)
    @user = user
    @product = product
    @direction = direction
    @quantity = quantity.to_i
    @reason = reason
    @note = note
  end

  def call
    raise Error, I18n.t("app.inventory.errors.invalid_quantity") unless @quantity.positive?
    raise Error, I18n.t("app.inventory.errors.invalid_reason") unless ADJUSTMENT_REASONS.include?(@reason)

    signed_quantity = @direction == "in" ? @quantity : -@quantity
    movement_type = @direction == "in" ? :adjustment_in : :adjustment_out

    InventoryService.record!(
      product: @product,
      quantity: signed_quantity,
      movement_type: movement_type,
      user: @user,
      note: adjustment_note
    )
  end

  private

  def adjustment_note
    reason_label = I18n.t("app.inventory.adjustment_reasons.#{@reason}")
    [ reason_label, @note.presence ].compact.join(" — ")
  end
end
