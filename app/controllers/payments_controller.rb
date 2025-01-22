class PaymentsController < ApplicationController
  before_action :authenticate_user!
  before_action :ensure_cart_exists
  
  def mpesa_checkout
    Rails.logger.info "Entering mpesa_checkout action"
    
    if params[:amount]
      # Direct product purchase
      @amount = params[:amount]
      render template: 'payments/mpesa_checkout', layout: 'application'
    elsif @cart && @cart.line_items.any?
      # Cart checkout
      Rails.logger.info "Cart: #{@cart.inspect}"
      render template: 'payments/mpesa_checkout', layout: 'application'
    else
      Rails.logger.info "No amount or cart specified"
      redirect_to root_path, alert: "Invalid checkout request"
    end
  rescue => e
    Rails.logger.error "Error in mpesa_checkout: #{e.message}"
    Rails.logger.error e.backtrace.join("\n")
    redirect_to root_path, alert: "An error occurred"
  end

  def process_mpesa_payment
    Rails.logger.info "Processing M-Pesa payment"
    
    # Format phone number (remove leading zero and add country code)
    raw_phone = params[:phone_number].strip
    phone_number = if raw_phone.start_with?('0')
                    "254#{raw_phone[1..-1]}"
                  elsif raw_phone.start_with?('254')
                    raw_phone
                  else
                    "254#{raw_phone}"
                  end
    
    amount = @cart.total_price.to_i # Convert to integer
    
    Rails.logger.info "Sending M-Pesa request for phone: #{phone_number}, amount: #{amount}"

    begin
      mpesa_client = MpesaClient.new
      response = mpesa_client.stk_push(
        phone_number: phone_number,
        amount: amount,
        account_reference: "Order##{Time.now.to_i}",
        transaction_desc: "Payment for order"
      )

      Rails.logger.info "M-Pesa API Response: #{response.inspect}"

      if response.success?
        # Store checkout request ID for callback handling
        session[:checkout_request_id] = response.checkout_request_id
        redirect_to payment_status_path, notice: "Please complete the payment on your phone"
      else
        Rails.logger.error "M-Pesa API Error: #{response.response_description}"
        redirect_to mpesa_checkout_path, 
          alert: "Failed to initiate payment try again later"
      end
    rescue => e
      Rails.logger.error "M-Pesa payment error: #{e.message}"
      Rails.logger.error e.backtrace.join("\n")
      redirect_to mpesa_checkout_path, 
        alert: "An error occurred while processing the payment. Please try again."
    end
  end

  private

  def ensure_cart_exists
    Rails.logger.info "Ensuring cart exists"
    if session[:cart_id]
      @cart = Cart.find_by(id: session[:cart_id])
    end
    
    if @cart.nil?
      @cart = Cart.create(user: current_user)
      session[:cart_id] = @cart.id
      Rails.logger.info "Created new cart with ID: #{@cart.id}"
    end
    
    Rails.logger.info "Current cart ID: #{@cart.id}"
  rescue => e
    Rails.logger.error "Cart error: #{e.message}"
    redirect_to root_path, alert: "Error accessing cart"
  end
end 