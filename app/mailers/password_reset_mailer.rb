class PasswordResetMailer < ApplicationMailer
  def reset_email(user, token)
    @user = user
    @reset_url = edit_password_reset_url(token: token, locale: I18n.locale)

    mail(
      to: user.email,
      subject: I18n.t("app.password_reset_mailer.subject")
    )
  end
end
