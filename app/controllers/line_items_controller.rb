class LineItemsController < ApplicationController
  before_action :set_line_item, only: %i[show update destroy]

  def show
    respond_to do |format|
      format.html { redirect_to cart_path(@line_item.cart) }
      format.json { render json: @line_item }
    end
  end

  def create
    product = Product.find(params[:product_id])
    @line_item = current_cart.add_product(product)

    respond_to do |format|
      if @line_item.save
        format.html { redirect_to cart_path(current_cart), notice: 'Added to your cart' }
        format.json { render :show, status: :created, location: @line_item }
      else
        format.html { redirect_back(fallback_location: root_path, alert: 'Could not add item to cart.') }
        format.json { render json: @line_item.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if @line_item.update(line_item_params)
        format.html { redirect_to cart_path(@line_item.cart), notice: 'Quantity updated.' }
        format.json { render :show, status: :ok, location: @line_item }
      else
        format.html { redirect_to cart_path(@line_item.cart), alert: 'Could not update quantity.' }
        format.json { render json: @line_item.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    cart = @line_item.cart
    @line_item.destroy

    respond_to do |format|
      format.html { redirect_to cart_path(cart), notice: 'Removed from your cart' }
      format.json { head :no_content }
    end
  end

  private

  def set_line_item
    @line_item = LineItem.find(params[:id])
  end

  def line_item_params
    params.require(:line_item).permit(:quantity)
  end

  def current_cart
    Cart.find(session[:cart_id])
  rescue ActiveRecord::RecordNotFound
    cart = Cart.create(user: current_user)
    session[:cart_id] = cart.id
    cart
  end
end
