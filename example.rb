# Example usage of the Bridge API Ruby gem

require_relative 'lib/bridge_api'

# Configure the gem globally
BridgeApi.config do |config|
  config.api_key = 'your-api-key-here'
  config.sandbox_mode = true  # Set to false for production
end

# Initialize a client
client = BridgeApi::Client.new

# Example: List wallets
puts "Listing wallets..."
response = client.list_wallets
if response.success?
  puts "Wallets: #{response.data}"
else
  puts "Error: #{response.error.message}"
end

# Example: Create a customer
puts "\nCreating a customer..."
customer_data = {
  # Add customer data here
}
response = client.create_customer(customer_data)
if response.success?
  puts "Customer created: #{response.data}"
else
  puts "Error: #{response.error.message}"
end

# Example: Get exchange rates
puts "\nGetting exchange rates..."
response = client.get_exchange_rates(from: 'USD', to: 'EUR')
if response.success?
  puts "Exchange rates: #{response.data}"
else
  puts "Error: #{response.error.message}"
end