#!/usr/bin/env ruby
# frozen_string_literal: true

# Example script to demonstrate webhook configuration for the Bridge API gem

# Set up Bundler to use the local gem
require 'bundler/setup'
require 'bridge_api'

# Load environment variables if available (for API key)
begin
  require 'dotenv/load'
rescue LoadError
  puts 'dotenv gem not available, environment variables will need to be set manually'
end

# Configure Bridge API (if not using environment variable)
BridgeApi.config do |config|
  # Use API key from environment variable or set here directly for testing
  config.api_key = ENV['BRIDGE_API_KEY'] || 'your-api-key-here'
  config.sandbox_mode = ENV['BRIDGE_SANDBOX_MODE'] ? ENV['BRIDGE_SANDBOX_MODE'].downcase == 'true' : true
end

puts 'Bridge API Configuration:'
puts "  API Key: #{BridgeApi.api_key ? '[SET]' : '[NOT SET]'}"
puts "  Sandbox Mode: #{BridgeApi.sandbox_mode}"
puts "  Base URL: #{BridgeApi.base_url}"
puts

# Webhook configuration example
puts 'Webhook Configuration Example:'
puts '==============================='
puts 'Webhook endpoint: https://96743bb22bbd.ngrok-free.app/bridge/webhook'
puts 'Monitored events: customer, kyc_link, virtual_account.activity'
puts

webhook_config = {
  url: 'https://96743bb22bbd.ngrok-free.app/bridge/webhook',
  event_categories: [
    'customer',
    'kyc_link', 
    'virtual_account.activity'
  ],
  active: true
}

puts "Configuration hash that would be sent to the API:"
webhook_config.each do |key, value|
  if value.is_a?(Array)
    puts "  #{key}: [#{value.join(', ')}]"
  else
    puts "  #{key}: #{value}"
  end
end
puts

if BridgeApi.api_key && !BridgeApi.api_key.include?('your-api-key')
  # Only try to make the API call if we have a real API key
  begin
    client = BridgeApi::Client.new(
      api_key: BridgeApi.api_key,
      sandbox_mode: BridgeApi.sandbox_mode,
    )
    puts 'Client initialized, attempting to create webhook...'
    
    response = client.webhooks.create(webhook_config)
    
    if response.success?
      puts '✓ Webhook created successfully!'
      puts "  Webhook ID: #{response.data.id}"
    else
      puts '✗ Error creating webhook:'
      puts "  Status: #{response.status_code}"
      puts "  Message: #{response.error.message}"
    end
  rescue StandardError => e
    puts "Exception occurred: #{e.message}"
  end
else
  puts "To create the webhook with a real API call, set your API key:"
  puts "  export BRIDGE_API_KEY='your-actual-api-key-here'"
  puts "  ruby exemples/webhook_example.rb"
  puts
  puts "Code example for creating the webhook:"
  puts
  puts "  client = BridgeApi::Client.new"
  puts "  webhook_config = {"
  puts "    url: 'https://96743bb22bbd.ngrok-free.app/bridge/webhook',"
  puts "    event_categories: ['customer', 'kyc_link', 'virtual_account.activity'],"
  puts "    active: true"
  puts "  }"
  puts "  response = client.webhooks.create(webhook_config)"
  puts "  if response.success?"
  puts "    puts \"Webhook created: \#{response.data.id}\""
  puts "  else"
  puts "    puts \"Error: \#{response.error.message}\""
  puts "  end"
end

puts
puts 'Webhook example completed.'

# Example of how to handle incoming webhook events
puts
puts 'Example Webhook Handler (for your server application):'
puts '====================================================='
puts <<~HANDLER
  # In your web application (Sinatra, Rails, etc.)
  
  post '/bridge/webhook' do
    # Verify webhook signature for security
    payload = request.body.read
    signature = request.env['HTTP_X_SIGNATURE']
    
    # Verify the signature here (implementation may vary)
    
    # Parse the webhook event
    event = JSON.parse(payload)
    
    case event['type']
    when 'customer'
      # Handle customer event
      puts "Customer event received: \#{event['data']}"
    when 'kyc_link'
      # Handle KYC link event
      puts "KYC link event received: \#{event['data']}"
    when 'virtual_account.activity'
      # Handle virtual account activity
      puts "Virtual account activity received: \#{event['data']}"
    else
      puts "Unknown event type: \#{event['type']}"
    end
    
    status 200
  end
HANDLER