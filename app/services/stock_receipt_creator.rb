class StockReceiptCreator
  class Error < StandardError; end

  def initialize(user:, received_on:, supplier: nil, note: nil, lines:)
    @user = user
    @received_on = received_on
    @supplier = supplier
    @note = note
    @lines = lines.select { |line| line[:quantity].to_i.positive? }
  end

  def call
    raise Error, I18n.t("app.inventory.errors.receipt_lines_required") if @lines.empty?

    receipt = nil

    ActiveRecord::Base.transaction do
      receipt = StockReceipt.create!(
        user: @user,
        received_on: @received_on,
        supplier: @supplier,
        note: @note
      )

      @lines.each do |line|
        product = Product.find(line[:product_id])
        quantity = line[:quantity].to_i

        StockReceiptLine.create!(
          stock_receipt: receipt,
          product: product,
          quantity: quantity
        )

        InventoryService.record!(
          product: product,
          quantity: quantity,
          movement_type: :inbound,
          user: @user,
          reference: receipt,
          note: receipt_note
        )
      end
    end

    receipt
  end

  private

  def receipt_note
    parts = []
    parts << @supplier if @supplier.present?
    parts << @note if @note.present?
    parts.join(" — ").presence
  end
end
