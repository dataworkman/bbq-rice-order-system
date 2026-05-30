class SessionsController < ApplicationController
  def new
    redirect_to root_path if logged_in?
  end

  def create
    user = User.find_by(email: params[:email]&.downcase)

    if user&.authenticate(params[:password])
      session[:user_id] = user.id
      redirect_to user.admin? ? admin_root_path : root_path, notice: t("app.flash.logged_in")
    else
      flash.now[:alert] = t("app.flash.invalid_credentials")
      render :new, status: :unprocessable_entity
    end
  end

  def destroy
    locale = session[:locale]
    reset_session
    session[:locale] = locale if locale
    redirect_to login_path, notice: t("app.flash.logged_out")
  end
end
