class ProductsController < ApplicationController
  before_action :require_owner

  def index
    @products = Product.active.order(:category, :name).group_by(&:category)
    load_cart_products
  end
end
