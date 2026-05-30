class ApplicationController < ActionController::Base
  include Cart
  include ActionView::RecordIdentifier

  allow_browser versions: :modern

  before_action :set_locale

  helper_method :current_user, :logged_in?, :admin?

  private

  def set_locale
    locale = session[:locale]&.to_sym
    locale = I18n.default_locale unless locale && I18n.available_locales.include?(locale)
    I18n.locale = locale
  end

  def current_user
    @current_user ||= User.find_by(id: session[:user_id]) if session[:user_id]
  end

  def logged_in?
    current_user.present?
  end

  def admin?
    current_user&.admin?
  end

  def require_login
    return if logged_in?

    redirect_to login_path, alert: t("app.flash.login_required")
  end

  def require_owner
    require_login
    return unless logged_in?
    return if current_user.owner?

    redirect_to admin_root_path, alert: t("app.flash.owner_only")
  end

  def require_admin
    require_login
    return unless logged_in?
    return if current_user.admin?

    redirect_to root_path, alert: t("app.flash.admin_required")
  end
end
