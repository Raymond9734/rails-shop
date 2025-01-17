class MpesaClient
    require 'httparty'
    include HTTParty
    base_uri 'https://sandbox.safaricom.co.ke'
  
    def initialize
      @consumer_key = ENV.fetch('MPESA_CONSUMER_KEY') { raise "MPESA_CONSUMER_KEY is not set" }
      @consumer_secret = ENV.fetch('MPESA_CONSUMER_SECRET') { raise "MPESA_CONSUMER_SECRET is not set" }
      @passkey = ENV.fetch('MPESA_PASSKEY') { raise "MPESA_PASSKEY is not set" }
      @shortcode = ENV.fetch('MPESA_SHORTCODE') { raise "MPESA_SHORTCODE is not set" }
      @callback_url = ENV.fetch('MPESA_CALLBACK_URL') { raise "MPESA_CALLBACK_URL is not set" }
    end
  
    def stk_push(phone_number:, amount:, account_reference:, transaction_desc:)
      Rails.logger.info "Initiating STK Push"
      Rails.logger.info "Phone: #{phone_number}, Amount: #{amount}"
      
      timestamp = Time.now.strftime('%Y%m%d%H%M%S')
      password = Base64.strict_encode64("#{@shortcode}#{@passkey}#{timestamp}")
  
      access_token = generate_access_token
      Rails.logger.info "Generated access token: #{access_token}"
  
      headers = {
        'Authorization' => "Bearer #{access_token}",
        'Content-Type' => 'application/json',
        'Accept' => 'application/json'
      }
  
      body = {
        BusinessShortCode: @shortcode,
        Password: password,
        Timestamp: timestamp,
        TransactionType: "CustomerPayBillOnline",
        Amount: amount,
        PartyA: phone_number,
        PartyB: @shortcode,
        PhoneNumber: phone_number,
        CallBackURL: @callback_url,
        AccountReference: account_reference,
        TransactionDesc: transaction_desc
      }
  
      Rails.logger.info "Request headers: #{headers.inspect}"
      Rails.logger.info "Request body: #{body.to_json}"
      Rails.logger.info "Making API request to Safaricom"
      
      response = self.class.post(
        '/mpesa/stkpush/v1/processrequest',
        headers: headers,
        body: body.to_json
      )
      
      Rails.logger.info "API Response Code: #{response.code}"
      Rails.logger.info "API Response Body: #{response.body}"
      handle_response(response)
    rescue => e
      Rails.logger.error "STK Push Error: #{e.message}"
      Rails.logger.error e.backtrace.join("\n")
      OpenStruct.new(
        success?: false,
        response_description: "An error occurred: #{e.message}"
      )
    end
  
    private
  
    def generate_access_token
      credentials = Base64.strict_encode64("#{@consumer_key}:#{@consumer_secret}")

      Rails.logger.info "============(Credentials: #{credentials})============"
      
      response = self.class.get(
        '/oauth/v1/generate?grant_type=client_credentials',
        headers: { 
          'Authorization' => "Basic #{credentials}",
          'Content-Type' => 'application/json',
          'Accept' => 'application/json'
        }
      )
  
      unless response.success?
        Rails.logger.error "Failed to get access token. Response: #{response.inspect}"
        raise "Failed to get access token. HTTP Status: #{response.code}"
      end
  
      parsed_response = JSON.parse(response.body)
      token = parsed_response['access_token']
      
      if token.nil? || token.empty?
        Rails.logger.error "No access token in response. Response body: #{response.body}"
        raise "No access token in response"
      end
      
      Rails.logger.info "Successfully generated access token"
      token
    end
  
    def handle_response(response)
      parsed_response = response.parsed_response
      Rails.logger.info "Parsed Response: #{parsed_response.inspect}"
      
      OpenStruct.new(
        success?: response.code == 200,
        checkout_request_id: parsed_response['CheckoutRequestID'],
        response_code: parsed_response['ResponseCode'],
        response_description: parsed_response['ResponseDescription'] || parsed_response['errorMessage']
      )
    end
  end