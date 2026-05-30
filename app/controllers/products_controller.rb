class ProductsController < ApplicationController
  before_action :require_owner

  def index
    @products = Product.active.by_item_number.group_by(&:category)
    load_cart_products
  end
end
