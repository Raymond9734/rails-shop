module CurrentCart
    extend ActiveSupport::Concern
  
    included do
      before_action :set_cart
    end
  
    private
  
    def set_cart
      if user_signed_in?
        @cart = current_user.cart || current_user.create_cart
        session[:cart_id] = @cart.id
      elsif session[:cart_id]
        @cart = Cart.find_by(id: session[:cart_id])
        if @cart.nil?
          @cart = Cart.create
          session[:cart_id] = @cart.id
        end
      end
    rescue ActiveRecord::RecordNotFound
      @cart = Cart.create
      session[:cart_id] = @cart.id
    end
end
