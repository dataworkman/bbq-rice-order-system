class ApplicationMailer < ActionMailer::Base
  helper ApplicationHelper

  default from: "from@example.com"
  layout "mailer"

  before_action :set_mailer_locale

  private

  def set_mailer_locale
    I18n.locale = params[:locale] if params[:locale].present?
  end
end
