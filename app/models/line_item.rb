class LineItem < ApplicationRecord
    belongs_to :product
    belongs_to :cart

    validates :product_id, :cart_id, :quantity, presence: true
    validates :quantity, numericality: { greater_than_or_equal_to: 1 }

    def total_price
        return 0 unless product&.price
        product.price * (quantity || 1)
    end
end