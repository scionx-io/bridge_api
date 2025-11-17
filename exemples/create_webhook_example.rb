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

# Webhook configuration
webhook_config = {
  url: 'https://96743bb22bbd.ngrok-free.app/bridge/webhook',
  event_epoch: 'webhook_creation',
  event_categories: [
    'customer',
    'kyc_link',
    'virtual_account.activity',
    'transfer'
  ]
}

puts 'Creating webhook...'
puts "URL: #{webhook_config[:url]}"
puts "Events: #{webhook_config[:event_categories].join(', ')}"
puts

begin
  response = client.webhooks.create(webhook_config)

  if response.success?
    webhook = response.data
    puts '✓ Webhook created successfully!'
    puts "  ID: #{webhook.id}"
    puts "  URL: #{webhook.url}"
    puts "  Status: #{webhook.status}"
    puts "  Events: #{webhook.event_categories.join(', ')}"
    puts "  Created: #{webhook.created_at}"
    puts "  Public Key:"
    puts webhook.public_key
  else
    puts '✗ Error creating webhook:'
    puts "  Status: #{response.status_code}"
    puts "  Error: #{response.error.message}"
  end
rescue StandardError => e
  puts "Exception occurred: #{e.class} - #{e.message}"
  puts e.backtrace.first(5).join("\n")
end
