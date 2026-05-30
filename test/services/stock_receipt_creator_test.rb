require "test_helper"

class StockReceiptCreatorTest < ActiveSupport::TestCase
  setup do
    @admin = User.create!(
      email: "admin-receipt@example.com",
      password: "password123",
      password_confirmation: "password123",
      role: :admin
    )
    @product = Product.create!(
      item_number: "RCP-001",
      name: "Receipt Product",
      category: "Test",
      unit_price: 100,
      stock: 10,
      unit: "ea"
    )
  end

  test "creates receipt and inbound movements" do
    receipt = StockReceiptCreator.new(
      user: @admin,
      received_on: Date.current,
      supplier: "Test Supplier",
      note: "Morning delivery",
      lines: [ { product_id: @product.id, quantity: 25 } ]
    ).call

    assert_equal 35, @product.reload.stock
    assert_equal 1, receipt.stock_receipt_lines.count
    assert_equal 1, StockMovement.inbound.count
  end

  test "requires at least one line" do
    assert_raises StockReceiptCreator::Error do
      StockReceiptCreator.new(
        user: @admin,
        received_on: Date.current,
        lines: []
      ).call
    end
  end
end
