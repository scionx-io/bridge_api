#!/usr/bin/env ruby
# frozen_string_literal: true

# Example script to demonstrate retrieving a customer using the Bridge API gem

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

# Create client
begin
  client = BridgeApi::Client.new(
    api_key: BridgeApi.api_key,
    sandbox_mode: BridgeApi.sandbox_mode,
  )
  puts 'Client initialized successfully'
rescue StandardError => e
  puts "Error initializing client: #{e.message}"
  exit 1
end

# The specific customer ID to retrieve
customer_id = 'f558b609-403f-4e88-8815-a1bc69c57159'

puts "Retrieving customer with ID: #{customer_id}"
puts

begin
  # Method 1: Using the service-based API pattern (recommended)
  customer = client.customers.retrieve(customer_id)

  # Check if the return value is an error response instead of a customer object
  if customer.is_a?(BridgeApi::Client::Response)
    # If it's a response object, it means there was an error
    puts '✗ Error retrieving customer:'
    puts "  Status Code: #{customer.status_code}"
    puts "  Error: #{customer.error&.message || 'Unknown error'}"

    # Provide helpful information for common errors
    case customer.status_code
    when 404
      puts "  Note: Customer with ID #{customer_id} was not found. Please verify the ID is correct."
    when 401
      puts '  Note: Authentication failed. Please verify your API key is correct.'
    when 403
      puts '  Note: Access forbidden. Please verify your API key has the required permissions.'
    end
  else
    # If we get here, it's a Customer object
    puts '✓ Customer retrieved successfully!'
    puts
    puts 'Customer details:'
    puts "  ID: #{customer.id}"
    puts "  Email: #{customer.email}"
    puts "  First Name: #{customer.first_name}"
    puts "  Last Name: #{customer.last_name}"
    puts "  Created At: #{customer.created_at}"
    puts "  Updated At: #{customer.updated_at}"

    # Note: the customer object might have other attributes not covered by explicit methods
  end
rescue StandardError => e
  puts 'Exception occurred while retrieving customer:'
  puts "  Error: #{e.message}"
  puts "  Backtrace: #{e.backtrace.first(5).join("\n           ")}"
end

puts
puts 'Alternative method using resource class directly:'
begin
  # Method 2: Using the resource class directly
  customer = BridgeApi::Resources::Customer.retrieve(client, customer_id)

  if customer.is_a?(BridgeApi::Resources::Customer)
    puts '✓ Customer retrieved using resource class:'
    puts "  ID: #{customer.id}"
    puts "  Email: #{customer.email}"
    puts "  First Name: #{customer.first_name}"
    puts "  Last Name: #{customer.last_name}"
  else
    puts '  Could not retrieve customer using resource class directly'
  end
rescue StandardError => e
  puts "Exception using resource class: #{e.message}"
end

puts
puts 'Script completed.'
