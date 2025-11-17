require 'dotenv/load'
require 'bridge_api'

# Configure Bridge API
BridgeApi.config do |config|
  config.api_key = ENV['BRIDGE_API_KEY']
  config.sandbox_mode = ENV['BRIDGE_SANDBOX_MODE'] ? ENV['BRIDGE_SANDBOX_MODE'].downcase == 'true' : true
end

client = BridgeApi::Client.new(
  api_key: BridgeApi.api_key,
  sandbox_mode: BridgeApi.sandbox_mode,
)

# First, list webhooks to get the latest one
puts 'Fetching webhooks...'
list_response = client.webhooks.list

unless list_response.success?
  puts '✗ Failed to fetch webhooks'
  exit 1
end

webhooks = list_response.data.data
if webhooks.empty?
  puts '✗ No webhooks found'
  exit 1
end

# Get the most recent webhook (last in the list)
latest_webhook = webhooks.last

puts "Found latest webhook:"
puts "  ID: #{latest_webhook.id}"
puts "  URL: #{latest_webhook.url}"
puts "  Current Status: #{latest_webhook.status}"
puts

# Update webhook to active status
puts 'Activating webhook...'

update_params = {
  status: 'active'
}

begin
  response = client.webhooks.update(latest_webhook.id, update_params)

  if response.success?
    webhook = response.data
    puts '✓ Webhook updated successfully!'
    puts "  ID: #{webhook.id}"
    puts "  URL: #{webhook.url}"
    puts "  New Status: #{webhook.status}"
    puts "  Events: #{webhook.event_categories.join(', ')}"
  else
    puts '✗ Error updating webhook:'
    puts "  Status: #{response.status_code}"
    puts "  Error: #{response.error.message}"
  end
rescue StandardError => e
  puts "Exception occurred: #{e.class} - #{e.message}"
  puts e.backtrace.first(5).join("\n")
end
