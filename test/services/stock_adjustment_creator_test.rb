require "test_helper"

class StockAdjustmentCreatorTest < ActiveSupport::TestCase
  setup do
    @admin = User.create!(
      email: "admin-adjust@example.com",
      password: "password123",
      password_confirmation: "password123",
      role: :admin
    )
    @product = Product.create!(
      item_number: "ADJ-001",
      name: "Adjust Product",
      category: "Test",
      unit_price: 100,
      stock: 20,
      unit: "ea"
    )
  end

  test "creates decrease adjustment" do
    StockAdjustmentCreator.new(
      user: @admin,
      product: @product,
      direction: "out",
      quantity: 5,
      reason: "damage",
      note: "freezer failure"
    ).call

    assert_equal 15, @product.reload.stock
    assert_equal 1, StockMovement.adjustment_out.count
  end

  test "creates increase adjustment" do
    StockAdjustmentCreator.new(
      user: @admin,
      product: @product,
      direction: "in",
      quantity: 3,
      reason: "count"
    ).call

    assert_equal 23, @product.reload.stock
    assert_equal 1, StockMovement.adjustment_in.count
  end
end
