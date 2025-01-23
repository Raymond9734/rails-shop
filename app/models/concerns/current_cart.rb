module CurrentCart
    extend ActiveSupport::Concern
  
    included do
      before_action :set_cart
    end
  
    private
  
    def set_cart
      if user_signed_in?
        @cart = current_user.cart || current_user.create_cart
        merge_guest_cart_if_exists
      else
        @cart = Cart.find_by(id: session[:cart_id])
        @cart ||= Cart.create
        session[:cart_id] = @cart.id
      end
    end

    def merge_guest_cart_if_exists
      return unless session[:cart_id]
      
      guest_cart = Cart.find_by(id: session[:cart_id])
      if guest_cart && guest_cart.id != @cart.id
        guest_cart.line_items.each do |item|
          existing_item = @cart.line_items.find_by(product_id: item.product_id)
          
          if existing_item
            existing_item.update(quantity: existing_item.quantity + item.quantity)
          else
            new_item = @cart.line_items.build(
              product_id: item.product_id,
              quantity: item.quantity
            )
            new_item.save
          end
        end
        
        guest_cart.destroy
        session[:cart_id] = @cart.id
      end
    end
end
