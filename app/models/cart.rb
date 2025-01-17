class Cart < ApplicationRecord
    belongs_to :user, optional: true
    has_many :line_items, dependent: :destroy
    has_many :products, through: :line_items
    
    def add_product(product)
      current_item = line_items.find_by(product_id: product.id)
      
      if current_item
        current_item.increment(:quantity)
      else
        current_item = line_items.build(product_id: product.id)
      end
      current_item
    end

    def total_price
      line_items.sum { |item| item.total_price }
    end
  end