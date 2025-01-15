class Product < ApplicationRecord
  before_destroy :not_referenced_by_any_line_item
  belongs_to :user, optional: true

  mount_uploader :image, ImageUploader
  serialize :image, JSON # If you use SQLite, add this line

  validates :title, :brand, :price, :model, :category, :description, :condition, :finish, :image, presence: true
  
  # Set max length to the description, price and title 
  validates :description, length: { maximum: 1000, too_long: "%{count} characters is the maximum aloud. "}
  validates :title, length: { maximum: 140, too_long: "%{count} characters is the maximum aloud. "}
  validates :price, numericality: { greater_than: 0, less_than: 10000000 }  

  # Validate image format
  validates :image, file_size: { less_than: 5.megabytes },
                   file_content_type: { allow: ['image/jpeg', 'image/png', 'image/gif'] }

  # You can input more brands finish and condition here
  BRAND = %w{ Ferrari Opel Lenovo Fossil Apple Samsung Nike Adidas Sony Microsoft Mercedes }
  FINISH = %w{ Black White Navy Blue Red Clear Satin Yellow Seafoam }
  CONDITION = %w{ New Excellent Mint Used Fair Poor }
  CATEGORIES = %w{ Cars Electronics Clothing Computers Phones Sports Books Home Garden Beauty Toys }

  private

  def not_referenced_by_any_line_item
    unless line_items.empty?
      errors.add(:base, 'Line items present')
      throw :abort
    end
  end
end
