module CurrentCart
    extend ActiveSupport::Concern
  
    included do
      before_action :set_cart
    end
  
    private
  
    def set_cart
      if current_user
        @cart = Cart.find_or_create_by(user_id: current_user.id)
      else
        @cart = nil
      end
    end
end
