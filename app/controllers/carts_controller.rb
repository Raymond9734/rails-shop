class CartsController < ApplicationController
  rescue_from ActiveRecord::RecordNotFound, with: :invalid_cart
  before_action :set_cart, only: [:show, :destroy]

  def show
  end

  def destroy
    @cart.line_items.destroy_all  # First destroy all line items
    @cart.destroy                 # Then destroy the cart itself
    session[:cart_id] = nil       # Clear the cart from session
    
    respond_to do |format|
      format.html { redirect_to root_path, notice: 'Your cart has been emptied' }
      format.json { head :no_content }
    end
  end

  private

  def invalid_cart
    logger.error "Attempt to access invalid cart #{params[:id]}"
    redirect_to root_path, notice: "That cart doesn't exist"
  end
end
