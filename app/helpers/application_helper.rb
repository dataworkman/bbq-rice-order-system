module ApplicationHelper
  # Amounts are stored in USD cents
  def format_money(cents)
    number_to_currency(cents / 100.0)
  end

  def locale_name(locale)
    t("app.locale.#{locale}")
  end
end
