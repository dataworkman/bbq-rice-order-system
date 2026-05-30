module Cart
  extend ActiveSupport::Concern

  included do
    helper_method :cart_items, :cart_count, :cart_total, :cart_quantity_for if respond_to?(:helper_method)
  end

  def cart_items
    session[:cart] ||= {}
  end

  def cart_count
    cart_items.values.sum(&:to_i)
  end

  def cart_quantity_for(product)
    cart_items[product.id.to_s].to_i
  end

  def load_cart_products
    @cart_products = Product.where(id: cart_items.keys).index_by { |p| p.id.to_s }
  end

  def cart_total
    return 0 if cart_items.blank?

    products = Product.where(id: cart_items.keys)
    cart_items.sum do |product_id, quantity|
      product = products.find { |item| item.id == product_id.to_i }
      next 0 unless product

      product.unit_price * quantity.to_i
    end
  end

  def clear_cart!
    session[:cart] = {}
  end
end
