require "test_helper"

class InventoryServiceTest < ActiveSupport::TestCase
  setup do
    @admin = User.create!(
      email: "admin-inventory@example.com",
      password: "password123",
      password_confirmation: "password123",
      role: :admin
    )
    @product = Product.create!(
      item_number: "TST-001",
      name: "Test Product",
      category: "Test",
      unit_price: 100,
      stock: 50,
      unit: "ea"
    )
  end

  test "records inbound movement and updates stock" do
    movement = InventoryService.record!(
      product: @product,
      quantity: 20,
      movement_type: :inbound,
      user: @admin,
      note: "delivery"
    )

    assert_equal 70, @product.reload.stock
    assert_equal 70, movement.balance_after
    assert_equal "inbound", movement.movement_type
  end

  test "records outbound movement" do
    InventoryService.record!(
      product: @product,
      quantity: -10,
      movement_type: :order_out,
      user: @admin
    )

    assert_equal 40, @product.reload.stock
  end

  test "prevents negative stock" do
    assert_raises InventoryService::InsufficientStockError do
      InventoryService.record!(
        product: @product,
        quantity: -100,
        movement_type: :adjustment_out,
        user: @admin
      )
    end

    assert_equal 50, @product.reload.stock
    assert_equal 0, StockMovement.count
  end
end
