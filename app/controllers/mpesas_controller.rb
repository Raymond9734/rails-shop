class MpesasController < ApplicationController
  skip_before_action :verify_authenticity_token, only: [:stkpush]
  before_action :authenticate_user!, except: [:stkpush]

  def index
    @mpesas = Mpesa.all
  end

  def generate_access_token_request
    @url = "https://sandbox.safaricom.co.ke/oauth/v1/generate?grant_type=client_credentials"
    @consumer_key = ENV['MPESA_CONSUMER_KEY']
    @consumer_secret = ENV['MPESA_CONSUMER_SECRET']

    # Ensure consumer key and secret are present
    if @consumer_key.nil? || @consumer_secret.nil?
      Rails.logger.error("Consumer key or secret is not set in environment variables.")
      raise "Consumer key or secret is missing"
    end

    @userpass = Base64.strict_encode64("#{@consumer_key}:#{@consumer_secret}")
    headers = {
      Authorization: "Basic #{@userpass}"
    }

    begin
      res = RestClient::Request.execute(url: @url, method: :get, headers: headers)
      Rails.logger.info("Access token request successful: #{res.body}")
    rescue RestClient::ExceptionWithResponse => e
      Rails.logger.error("Access token request failed: #{e.response.body}")
      raise
    rescue RestClient::Exception => e
      Rails.logger.error("Access token request failed: #{e.message}")
      raise
    end

    res
  end

  def get_access_token
    res = generate_access_token_request()
    if res.code != 200
      r = generate_access_token_request()
      if res.code != 200
        raise MpesaError('Unable to generate access token')
      end
    end
    body = JSON.parse(res, { symbolize_names: true })
    token = body[:access_token]
    AccessToken.destroy_all()
    AccessToken.create!(token: token)
    token
  end

  def stkpush
    raw_phone = params[:phoneNumber]
    if raw_phone.blank?
      Rails.logger.error("Phone number is missing")
      render json: { error: "Phone number is required" }, status: :bad_request
      return
    end

    # Format phone number (remove leading zero and add country code)
    phoneNumber = if raw_phone.start_with?('0')
                   "254#{raw_phone[1..-1]}"
                 elsif raw_phone.start_with?('254')
                   raw_phone
                 else
                   "254#{raw_phone}"
                 end

    Rails.logger.info("Phone number used for STK push: #{phoneNumber}")
    amount = params[:amount]
    url = "https://sandbox.safaricom.co.ke/mpesa/stkpush/v1/processrequest"
    timestamp = "#{Time.now.strftime "%Y%m%d%H%M%S"}"
    business_short_code = ENV["MPESA_SHORTCODE"]
    password = Base64.strict_encode64("#{business_short_code}#{ENV["MPESA_PASSKEY"]}#{timestamp}")
    payload = {
      'BusinessShortCode': business_short_code,
      'Password': password,
      'Timestamp': timestamp,
      'TransactionType': "CustomerPayBillOnline",
      'Amount': amount,
      'PartyA': phoneNumber,
      'PartyB': business_short_code,
      'PhoneNumber': phoneNumber,
      'CallBackURL': "#{ENV["CALLBACK_URL"]}/callback_url",
      'AccountReference': 'Codearn',
      'TransactionDesc': "Payment for Codearn premium"
    }.to_json

    headers = {
      Content_type: 'application/json',
      Authorization: "Bearer #{get_access_token}"
    }

    response = RestClient::Request.new({
      method: :post,
      url: url,
      payload: payload,
      headers: headers
    }).execute do |response, request|
      case response.code
      when 500
        [ :error, JSON.parse(response.to_str) ]
      when 400
        [ :error, JSON.parse(response.to_str) ]
      when 200
        [ :success, JSON.parse(response.to_str) ]
      else
        fail "Invalid response #{response.to_str} received."
      end
    end
    render json: response
  end

  
  private

  def mpesa_params
    params.require(:mpesa).permit(:phone_number, :amount)
  end
end
