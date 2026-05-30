class PasswordResetsController < ApplicationController
  before_action :redirect_if_logged_in, only: %i[new create edit update]
  before_action :set_user_from_token, only: %i[edit update]

  def new
  end

  def create
    user = User.find_by(email: params[:email]&.downcase)

    if user
      token = user.generate_token_for(:password_reset)
      PasswordResetMailer.reset_email(user, token).deliver_later
    end

    redirect_to login_path, notice: t("app.flash.password_reset_sent")
  end

  def edit
  end

  def update
    if @user.update(password_reset_params)
      redirect_to login_path, notice: t("app.flash.password_reset_complete")
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def redirect_if_logged_in
    redirect_to root_path if logged_in?
  end

  def set_user_from_token
    @user = User.find_by_token_for(:password_reset, params[:token])
    return if @user

    redirect_to new_password_reset_path, alert: t("app.flash.password_reset_invalid")
  end

  def password_reset_params
    params.require(:user).permit(:password, :password_confirmation)
  end
end
