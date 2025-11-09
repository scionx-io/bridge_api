# frozen_string_literal: true

# Coverage reporting
require 'simplecov'
SimpleCov.start do
  add_filter '/test/'
end

require 'minitest/autorun'
require 'webmock/minitest'
require_relative '../lib/bridge_api'

class BridgeApiTest < Minitest::Test
  def setup
    # Reset global configuration before each test
    BridgeApi.api_key = nil
    BridgeApi.sandbox_mode = nil
  end

  def test_that_gem_has_a_version
    refute_nil ::BridgeApi::VERSION
  end

  def test_client_initialization
    assert_raises(ArgumentError) do
      BridgeApi::Client.new(api_key: nil)
    end

    assert_raises(ArgumentError) do
      BridgeApi::Client.new(api_key: '')
    end
  end

  def test_global_configuration
    BridgeApi.config do |c|
      c.api_key = 'test-key'
      c.sandbox_mode = true
    end

    assert_equal 'test-key', BridgeApi.api_key
    assert_equal true, BridgeApi.sandbox_mode
  end

  def test_successful_api_request
    # Mock the API response
    stub_request(:get, 'https://api.sandbox.bridge.xyz/v0/customers')
      .with(headers: { 'Api-Key' => 'test-key-123' })
      .to_return(
        status: 200,
        body: { data: [{ id: 'cust_123', email: 'test@example.com' }] }.to_json,
        headers: { 'Content-Type' => 'application/json' }
      )

    client = BridgeApi::Client.new(api_key: 'test-key-123', sandbox_mode: true)
    response = client.list_customers

    assert response.success?
    assert_equal 200, response.status_code
    refute_nil response.data
  end

  def test_api_authentication_error
    # Mock 401 response
    stub_request(:get, 'https://api.sandbox.bridge.xyz/v0/customers')
      .to_return(status: 401, body: { message: 'Invalid API key' }.to_json)

    client = BridgeApi::Client.new(api_key: 'invalid-key', sandbox_mode: true)
    response = client.list_customers

    refute response.success?
    assert_equal 401, response.status_code
    assert_instance_of BridgeApi::AuthenticationError, response.error
  end
end
