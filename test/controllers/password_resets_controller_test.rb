require "test_helper"

class PasswordResetsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @franchise = Franchise.create!(
      name: "Test Franchise",
      address: "123 Test St",
      owner_email: "owner@example.com"
    )
    @owner = User.create!(
      email: "owner@example.com",
      password: "oldpassword1",
      password_confirmation: "oldpassword1",
      role: :owner,
      franchise: @franchise
    )
  end

  test "request sends reset email for known owner" do
    assert_emails 1 do
      post password_reset_path, params: { email: @owner.email }
    end

    assert_redirected_to login_path
    assert_equal I18n.t("app.flash.password_reset_sent"), flash[:notice]
  end

  test "request does not reveal unknown email" do
    assert_no_emails do
      post password_reset_path, params: { email: "unknown@example.com" }
    end

    assert_redirected_to login_path
    assert_equal I18n.t("app.flash.password_reset_sent"), flash[:notice]
  end

  test "owner resets password with valid token" do
    token = @owner.generate_token_for(:password_reset)

    patch password_reset_path(token: token), params: {
      user: { password: "newpassword1", password_confirmation: "newpassword1" }
    }

    assert_redirected_to login_path
    assert @owner.reload.authenticate("newpassword1")
  end

  test "rejects invalid token" do
    get edit_password_reset_path(token: "invalid")

    assert_redirected_to new_password_reset_path
    assert_equal I18n.t("app.flash.password_reset_invalid"), flash[:alert]
  end
end
