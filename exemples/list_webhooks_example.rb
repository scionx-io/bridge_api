require 'dotenv/load'
require 'bridge_api'

# Configure Bridge API
BridgeApi.config do |config|
  # Use API key from environment variable or set here directly for testing
  config.api_key = ENV['BRIDGE_API_KEY'] 
  config.sandbox_mode = ENV['BRIDGE_SANDBOX_MODE'] ? ENV['BRIDGE_SANDBOX_MODE'].downcase == 'true' : true
end

client = BridgeApi::Client.new(
      api_key: BridgeApi.api_key,
      sandbox_mode: BridgeApi.sandbox_mode,
    )
    
    response = client.webhooks.list
    
      puts '✓ Webhooks retrieved successfully!'
        puts "Found #{response.data.length} webhook(s):"
        response.data.each do |webhook|
          puts "  - ID: #{webhook.id}"
          puts "    URL: #{webhook.url}"
          puts "    Status: #{webhook.status}"
          puts "    Events: #{webhook.event_categories.join(', ')}"
          puts "    Created: #{webhook.created_at}"
          puts
        end
