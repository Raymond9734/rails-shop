class ChangeProductPriceLimit < ActiveRecord::Migration[6.1]
  def change
    change_column :products, :price, :decimal, precision: 10, scale: 2, default: 0
  end
end