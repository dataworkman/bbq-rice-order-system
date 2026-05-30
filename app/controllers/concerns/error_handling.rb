module ErrorHandling
  extend ActiveSupport::Concern

  included do
    rescue_from ActiveRecord::RecordNotFound, with: :handle_not_found
    rescue_from ActionController::ParameterMissing, with: :handle_bad_request
    rescue_from ActiveRecord::RecordInvalid, with: :handle_invalid_record
    rescue_from ActionController::InvalidAuthenticityToken, with: :handle_invalid_token

    unless Rails.env.test?
      rescue_from StandardError, with: :handle_unexpected_error
    end
  end

  private

  def handle_not_found(_exception)
    respond_with_friendly_error(:not_found)
  end

  def handle_bad_request(_exception)
    respond_with_friendly_error(:bad_request)
  end

  def handle_invalid_record(_exception)
    respond_with_friendly_error(:invalid)
  end

  def handle_invalid_token(_exception)
    reset_session
    respond_with_friendly_error(:session_expired, fallback: login_path)
  end

  def handle_unexpected_error(exception)
    log_client_error(exception, level: :error)
    respond_with_friendly_error(:unexpected)
  end

  def respond_with_friendly_error(message_key, fallback: nil)
    message = friendly_error_message(message_key)
    path = fallback || contextual_fallback_path

    respond_to do |format|
      format.turbo_stream { render_friendly_flash(:alert, message) }
      format.html { redirect_to path, alert: message }
      format.any { redirect_to path, alert: message }
    end
  end

  def render_friendly_flash(type, message)
    render turbo_stream: turbo_stream.replace(
      "flash-messages",
      partial: "shared/flash_messages",
      locals: { type: type, message: message }
    )
  end

  def friendly_error_message(key)
    if admin_user?
      t("app.errors.admin.#{key}", default: t("app.errors.owner.#{key}"))
    else
      t("app.errors.owner.#{key}")
    end
  end

  def contextual_fallback_path
    case controller_path
    when "orders" then orders_path
    when "admin/orders" then admin_orders_path
    when "admin/products" then admin_products_path
    when "admin/franchises" then admin_franchises_path
    when "carts", "products" then products_path
    when "admin/dashboard" then admin_root_path
    else
      safe_home_path
    end
  end

  def safe_home_path
    return login_path unless logged_in?

    current_user.owner? ? products_path : admin_root_path
  end

  def admin_user?
    logged_in? && current_user.admin?
  end

  def log_client_error(exception, level: :warn)
    Rails.logger.public_send(level) do
      "[#{controller_path}##{action_name}] #{exception.class}: #{exception.message}"
    end
    return unless level == :error

    Rails.logger.error(exception.backtrace&.first(10)&.join("\n"))
  end
end
