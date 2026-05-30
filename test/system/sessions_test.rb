require "application_system_test_case"

class SessionsTest < ApplicationSystemTestCase
  setup do
    @franchise = Franchise.create!(
      name: "Test Franchise",
      address: "123 Test St, Los Angeles, CA 90012",
      owner_email: "owner@example.com"
    )
    @owner = User.create!(
      email: "owner@example.com",
      password: "password123",
      password_confirmation: "password123",
      role: :owner,
      franchise: @franchise
    )
    Product.create!(
      item_number: "BUN-001",
      name: "Burger Bun",
      category: "Buns & Rolls",
      unit_price: 45,
      stock: 100,
      unit: "ea"
    )
  end

  test "owner signs in and views products" do
    visit login_path

    fill_in :email, with: @owner.email
    fill_in :password, with: "password123"
    click_button I18n.t("app.sessions.login")

    assert_text I18n.t("app.flash.logged_in")
    assert_text "Burger Bun"
  end
end
