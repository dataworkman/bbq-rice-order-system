require "test_helper"

class FranchiseCreatorTest < ActiveSupport::TestCase
  test "creates franchise and owner account" do
    result = FranchiseCreator.call(
      name: "Test Store",
      address: "1 Test St",
      owner_email: "newowner@example.com"
    )

    assert result.success?
    assert result.initial_password.present?
    assert_equal "newowner@example.com", result.franchise.owner.email
  end

  test "rejects duplicate owner email" do
    existing = Franchise.create!(
      name: "Existing",
      address: "1 Main St",
      owner_email: "duplicate@example.com"
    )
    User.create!(
      email: "duplicate@example.com",
      password: "password123",
      password_confirmation: "password123",
      role: :owner,
      franchise: existing
    )

    result = FranchiseCreator.call(
      name: "Another Store",
      address: "2 Test St",
      owner_email: "duplicate@example.com"
    )

    assert_not result.success?
    assert result.franchise.errors[:owner_email].any?
    assert_equal 0, Franchise.where(name: "Another Store").count
  end
end
