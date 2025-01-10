# e-Commerce Shop Application - README

This document provides a comprehensive guide to implementing the missing features in the e-Commerce shop application built with Ruby on Rails. The project involves user authentication, product advertisements, and a shopping cart system. Below are the step-by-step instructions to implement the required features.

## Table of Contents
1. [Prerequisites](#prerequisites)
2. [Setting Up the Project](#setting-up-the-project)
3. [Implementing User Authentication](#implementing-user-authentication)
4. [Creating Product Ads](#creating-product-ads)
5. [Implementing the Shopping Cart](#implementing-the-shopping-cart)
6. [Bonus Features](#bonus-features)
7. [Conclusion](#conclusion)

## Prerequisites

Before starting, ensure you have the following installed:
- Ruby (version 2.7 or higher)
- Rails (version 6.x or higher)
- Bundler
- Node.js and Yarn (for asset management)
- PostgreSQL or SQLite (database)

## Setting Up the Project

1. **Clone the Repository:**
   ```bash
   git clone <repository-url>
   cd <project-directory>
   ```

2. **Install Dependencies:**
   ```bash
   bundle install
   yarn install
   ```

3. **Set Up the Database:**
   ```bash
   rails db:create
   rails db:migrate
   ```

4. **Run the Server:**
   ```bash
   rails server
   ```

## Implementing User Authentication

### Step 1: Install Devise

1. Add Devise to your Gemfile:
   ```ruby
   gem 'devise'
   ```

2. Install Devise:
   ```bash
   bundle install
   rails generate devise:install
   ```

3. Generate the User model:
   ```bash
   rails generate devise User
   rails db:migrate
   ```

### Step 2: Complete the Registrations Controller

1. Create the `RegistrationsController`:
   ```bash
   rails generate controller Registrations
   ```

2. Implement the `sign_up_params` and `account_update_params` methods in `app/controllers/registrations_controller.rb`:
   ```ruby
   class RegistrationsController < Devise::RegistrationsController
     private

     def sign_up_params
       params.require(:user).permit(:name, :email, :password, :password_confirmation)
     end

     def account_update_params
       params.require(:user).permit(:name, :email, :password, :password_confirmation, :current_password)
     end
   end
   ```

3. Update the routes to use the new controller:
   ```ruby
   devise_for :users, controllers: { registrations: 'registrations' }
   ```

## Creating Product Ads

### Step 1: Generate the Product Model

1. Generate the Product model:
   ```bash
   rails generate model Product title:string price:decimal model:string description:text brand:string color:string condition:string user_id:integer
   rails db:migrate
   ```

2. Add associations in `app/models/user.rb` and `app/models/product.rb`:
   ```ruby
   # app/models/user.rb
   class User < ApplicationRecord
     has_many :products, dependent: :destroy
   end

   # app/models/product.rb
   class Product < ApplicationRecord
     belongs_to :user
   end
   ```

### Step 2: Implement the Sell Feature

1. Create the `ProductsController`:
   ```bash
   rails generate controller Products
   ```

2. Implement the necessary actions (`new`, `create`, `edit`, `update`, `destroy`) in `app/controllers/products_controller.rb`.

3. Update the `products_helper.rb` to display the seller's name and restrict edit/delete actions to the product owner:
   ```ruby
   module ProductsHelper
     def seller_name(product)
       product.user.name
     end

     def can_edit_or_delete?(product)
       current_user == product.user
     end
   end
   ```

## Implementing the Shopping Cart

### Step 1: Generate the Cart Model

1. Generate the Cart model:
   ```bash
   rails generate model Cart user_id:integer
   rails db:migrate
   ```

2. Generate the LineItem model:
   ```bash
   rails generate model LineItem product_id:integer cart_id:integer quantity:integer
   rails db:migrate
   ```

3. Add associations in `app/models/cart.rb` and `app/models/line_item.rb`:
   ```ruby
   # app/models/cart.rb
   class Cart < ApplicationRecord
     belongs_to :user
     has_many :line_items, dependent: :destroy
   end

   # app/models/line_item.rb
   class LineItem < ApplicationRecord
     belongs_to :product
     belongs_to :cart
   end
   ```

### Step 2: Implement Cart Functionality

1. Create a concern `current_cart.rb` in `app/models/concerns/`:
   ```ruby
   module CurrentCart
     extend ActiveSupport::Concern

     included do
       before_action :set_cart
     end

     private

     def set_cart
       @cart = Cart.find_or_create_by(user_id: current_user.id)
     end
   end
   ```

2. Include the concern in your `ApplicationController`:
   ```ruby
   class ApplicationController < ActionController::Base
     include CurrentCart
   end
   ```

3. Implement the `CartsController` to handle adding/removing items and calculating the total:
   ```bash
   rails generate controller Carts
   ```

4. Add the shopping cart icon to the home page and display the number of items in the cart.

## Bonus Features

1. **Add Product Categories:**
   - Add a `category` field to the Product model.
   - Allow users to select a category when creating a product.

2. **Add More Product Fields:**
   - Add additional fields like `brand`, `size`, etc., to the Product model.

3. **Implement Payment Method:**
   - Integrate a payment gateway like Stripe or PayPal.

4. **Enhance UI/UX:**
   - Customize the design and layout of the application.

## Conclusion

By following these steps, you will have a fully functional e-Commerce shop application with user authentication, product advertisements, and a shopping cart system. Feel free to expand on the bonus features to further enhance the application. Happy coding!