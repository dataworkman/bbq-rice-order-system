class AccountController < ApplicationController
  before_action :require_login

  def edit
  end

  def update
    unless current_user.authenticate(account_params[:current_password].to_s)
      flash.now[:alert] = t("app.flash.current_password_invalid")
      return render :edit, status: :unprocessable_entity
    end

    if current_user.update(password: account_params[:password], password_confirmation: account_params[:password_confirmation])
      redirect_to after_update_path, notice: t("app.flash.password_changed")
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def account_params
    params.require(:account).permit(:current_password, :password, :password_confirmation)
  end

  def after_update_path
    current_user.admin? ? admin_root_path : root_path
  end
end
