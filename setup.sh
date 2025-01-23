#!/bin/bash

# Exit on error
set -e

echo "=== Setting up the application ==="

# Function to check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to install ngrok based on OS
install_ngrok() {
    if ! command_exists ngrok; then
        echo "Installing ngrok..."
        
        # Detect OS
        case "$(uname -s)" in
            Linux*)
                # Check for package managers
                if command_exists apt-get; then
                    curl -s https://ngrok-agent.s3.amazonaws.com/ngrok.asc | sudo tee /etc/apt/trusted.gpg.d/ngrok.asc >/dev/null
                    echo "deb https://ngrok-agent.s3.amazonaws.com buster main" | sudo tee /etc/apt/sources.list.d/ngrok.list
                    sudo apt-get update && sudo apt-get install ngrok
                elif command_exists snap; then
                    sudo snap install ngrok
                else
                    echo "Please install ngrok manually from https://ngrok.com/download"
                fi
                ;;
            Darwin*)
                # macOS
                if command_exists brew; then
                    brew install ngrok
                else
                    echo "Installing Homebrew first..."
                    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
                    brew install ngrok
                fi
                ;;
            MINGW*|CYGWIN*|MSYS*)
                # Windows
                echo "Please install ngrok manually from https://ngrok.com/download"
                echo "Or use: 'choco install ngrok' if you have Chocolatey installed"
                ;;
            *)
                echo "Unknown operating system. Please install ngrok manually from https://ngrok.com/download"
                ;;
        esac
    else
        echo "ngrok is already installed"
    fi
}

# Install ngrok if not present
install_ngrok

# Install Ruby dependencies
echo "Installing Ruby dependencies..."
bundle install

# Install JavaScript dependencies
echo "Installing JavaScript dependencies..."
yarn install

# Create .env file if it doesn't exist
create_env_file() {
    if [ ! -f .env ]; then
        echo "Creating .env file..."
        cat > .env << EOL
MPESA_CONSUMER_KEY='your_consumer_key'
MPESA_CONSUMER_SECRET='your_consumer_secret'
MPESA_PASSKEY='your_passkey'
MPESA_SHORTCODE='your_shortcode'
MPESA_INITIATOR_NAME='your_initiator_name'
MPESA_INITIATOR_PASSWORD='your_password'
CALLBACK_URL='your_ngrok_url'
REGISTER_URL='https://sandbox.safaricom.co.ke/mpesa/c2b/v1/registerurl'
EOL
        echo ".env file created successfully. Please update it with your actual credentials."
    else
        echo ".env file already exists"
    fi
}

# Setup the database
echo "Setting up the database..."
rails db:create 2>/dev/null || echo "Database already exists"
rails db:migrate 2>/dev/null || echo "Migrations failed or already up to date"
rails db:seed 2>/dev/null || echo "Seed data already exists or failed to seed"

# Create .env file
create_env_file

# Make the script executable
chmod +x bin/rails

echo "=== Setup completed successfully! ==="
echo
echo "To start the application:"
echo "1. Start the Rails server:"
echo "   $ rails server"
echo
echo "2. In a separate terminal, start ngrok:"
echo "   $ ngrok http 3000"
echo
echo "3. Update your .env file with the new ngrok URL:"
echo "   CALLBACK_URL: 'your-ngrok-url'"
echo
echo "Note: The ngrok URL changes each time you restart ngrok."
echo "      Make sure to update your .env file with the new URL."
echo
echo "If this is your first time using ngrok, you'll need to:"
echo "1. Sign up at https://ngrok.com"
echo "2. Get your authtoken from https://dashboard.ngrok.com/get-started/your-authtoken"
echo "3. Configure ngrok with your authtoken:"
echo "   $ ngrok config add-authtoken YOUR_AUTH_TOKEN" 