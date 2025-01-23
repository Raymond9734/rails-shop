# E-Commerce Shop with Mpesa Integration

A Ruby on Rails e-commerce application featuring user authentication, product management, shopping cart functionality, and Mpesa payment integration.

## Features

- User Authentication (using Devise)
- Product Management
- Shopping Cart System
- Mpesa Payment Integration
- Real-time Payment Status Updates

## Prerequisites

Before you begin, ensure you have the following installed:
- Ruby (2.7.0 or higher)
- Rails (6.0 or higher)
- PostgreSQL
- Node.js and Yarn
- Ngrok (for Mpesa callback URLs)

## Installation

1. Clone the repository:
   ```bash
   git clone https://github.com/Raymond9734/rails-shop.git
   cd rails-shop
   ```

2. Make the script Executable then Run the setup script:
   ```bash
   chmod +x ./setup.sh
   ./setup.sh
   ```

3. Configure your environment variables in `.env`:
   ```
   MPESA_CONSUMER_KEY: 'your_consumer_key'
   MPESA_CONSUMER_SECRET: 'your_consumer_secret'
   MPESA_PASSKEY: 'your_passkey'
   MPESA_SHORTCODE: 'your_shortcode'
   MPESA_INITIATOR_NAME: 'your_initiator_name'
   MPESA_INITIATOR_PASSWORD: 'your_password'
   CALLBACK_URL: 'your_ngrok_url'
   REGISTER_URL: "https://sandbox.safaricom.co.ke/mpesa/c2b/v1/registerurl"
   ```

4. Start the Rails server:
   ```bash
   rails server
   ```

5. In a separate terminal, start ngrok:
   ```bash
   ngrok http 3000
   ```

6. Update the callback URL in `.env` with your new ngrok URL:
   ```
   CALLBACK_URL: 'your-new-ngrok-url'
   ```

7. Run the test suite:
   ```bash
   rails test
   ```
