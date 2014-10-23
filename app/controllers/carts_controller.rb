class CartsController < ApplicationController
  def index
    @carts = Cart.all

    respond_to do |format|
      format.html
    end
  end
end
