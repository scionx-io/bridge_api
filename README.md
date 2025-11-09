# BridgeApi

A Ruby gem for interacting with the Bridge.xyz API. This gem provides easy access to Bridge's financial services API, supporting both sandbox and production environments.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'bridge_api'
```

And then execute:

```bash
$ bundle install
```

Or install it yourself:

```bash
$ gem install bridge_api
```

## Configuration

Configure the gem globally:

```ruby
BridgeApi.config do |c|
  c.api_key = 'your-api-key-here'
  c.sandbox_mode = true  # Set to false for production
end
```

## Usage

Initialize a client and make API calls:

```ruby
# Using global configuration
client = BridgeApi::Client.new

# Or with explicit parameters
client = BridgeApi::Client.new(api_key: 'your-api-key', sandbox_mode: true)

# Example: List wallets
response = client.list_wallets
if response.success?
  puts response.data
else
  puts "Error: #{response.error.message}"
end

# Example: Create a customer
response = client.create_customer(customer_data)
# Handle response...

# Example: Get exchange rates
response = client.get_exchange_rates(from: 'USD', to: 'EUR')
# Handle response...
```

The gem supports all Bridge API resources including wallets, customers, transfers, external accounts, and more.

## Error Handling

The gem provides custom error classes:

- `BridgeApi::AuthenticationError` - Authentication failures
- `BridgeApi::RateLimitError` - Rate limiting
- `BridgeApi::ApiError` - Other API errors

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).