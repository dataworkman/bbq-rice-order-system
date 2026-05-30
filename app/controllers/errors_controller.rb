class ErrorsController < ActionController::Base
  include ActionView::Helpers::TranslationHelper
  include ActionView::Helpers::UrlHelper

  layout "error"

  before_action :set_locale

  helper_method :logged_in?, :current_user

  def not_found
    render_error(:not_found, :not_found)
  end

  def unprocessable_entity
    render_error(:invalid, :unprocessable_entity)
  end

  def internal_server_error
    render_error(:unexpected, :internal_server_error)
  end

  private

  def set_locale
    locale = session[:locale]&.to_sym
    I18n.locale = locale if locale && I18n.available_locales.include?(locale)
  end

  def current_user
    @current_user ||= User.find_by(id: session[:user_id]) if session[:user_id]
  end

  def logged_in?
    current_user.present?
  end

  def render_error(message_key, status)
    @message = t("app.errors.owner.#{message_key}")
    @home_path = logged_in? ? (current_user.owner? ? products_path : admin_root_path) : login_path
    render "errors/show", status: status
  end
end
