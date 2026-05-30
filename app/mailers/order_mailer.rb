class OrderMailer < ApplicationMailer
  def order_confirmation(order)
    @order = order
    @franchise = order.franchise
    @items = order.order_items.includes(:product)
    @tax = (@order.total_amount * 0.1).round
    @grand_total = @order.total_amount + @tax

    mail(
      to: @franchise.owner_email,
      subject: I18n.t("app.mailer.subject", id: @order.id, name: @franchise.name)
    )
  end
end
