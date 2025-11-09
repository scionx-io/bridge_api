# frozen_string_literal: true

# Coverage reporting
require 'simplecov'
SimpleCov.start do
  add_filter '/test/'
end

require 'minitest/autorun'
require 'webmock/minitest'
require_relative '../lib/bridge_api'

class BridgeWalletsTest < Minitest::Test
  def setup
    # Reset global configuration before each test
    BridgeApi.api_key = nil
    BridgeApi.sandbox_mode = nil
  end

  def test_list_wallets_success
    # Mock the successful API response for listing wallets
    stub_request(:get, 'https://api.sandbox.bridge.xyz/v0/wallets').
      with(headers: { 'Api-Key' => 'test-key-123' }).
      to_return(
        status: 200,
        body: {
          count: 1,
          data: [
            {
              id: 'bw_123',
              chain: 'solana',
              address: '9kV3ZMehKVyxfHKCcaDLye3P9HHw2MP4jtQa2gKBUmCs',
              created_at: '2023-11-22T21:31:30.515Z',
              updated_at: '2023-11-22T21:31:30.515Z',
            },
          ],
        }.to_json,
        headers: { 'Content-Type' => 'application/json' },
      )

    client = BridgeApi::Client.new(api_key: 'test-key-123', sandbox_mode: true)
    response = client.list_wallets

    assert response.success?
    assert_equal 200, response.status_code
    refute_nil response.data
    assert_instance_of BridgeApi::ListObject, response.data
    assert_equal 1, response.data.count
    assert_equal 1, response.data.size
    assert_equal 'bw_123', response.data[0].id
    assert_equal 'solana', response.data[0].chain
    assert_equal '9kV3ZMehKVyxfHKCcaDLye3P9HHw2MP4jtQa2gKBUmCs', response.data[0].address
  end

  def test_list_wallets_with_parameters
    # Test the list wallets endpoint with query parameters (limit, starting_after, ending_before)
    stub_request(:get, 'https://api.sandbox.bridge.xyz/v0/wallets').
      with(
        headers: { 'Api-Key' => 'test-key-123' },
        query: { limit: 25, starting_after: 'bw_456' },
      ).
      to_return(
        status: 200,
        body: {
          count: 25,
          data: [
            {
              id: 'bw_789',
              chain: 'ethereum',
              address: '0x742d35Cc6634C0532925a3b844Bc454e4438f44e',
              created_at: '2023-11-23T21:31:30.515Z',
              updated_at: '2023-11-23T21:31:30.515Z',
            },
          ],
        }.to_json,
        headers: { 'Content-Type' => 'application/json' },
      )

    client = BridgeApi::Client.new(api_key: 'test-key-123', sandbox_mode: true)
    response = client.list_wallets(limit: 25, starting_after: 'bw_456')

    assert response.success?
    assert_equal 200, response.status_code
    refute_nil response.data
    assert_instance_of BridgeApi::ListObject, response.data
    assert_equal 25, response.data.count
    assert_equal 1, response.data.size
    assert_equal 'bw_789', response.data[0].id
    assert_equal 'ethereum', response.data[0].chain
  end

  def test_list_wallets_with_ending_before_parameter
    # Test the list wallets endpoint with ending_before parameter
    stub_request(:get, 'https://api.sandbox.bridge.xyz/v0/wallets').
      with(
        headers: { 'Api-Key' => 'test-key-123' },
        query: { ending_before: 'bw_999' },
      ).
      to_return(
        status: 200,
        body: {
          count: 5,
          data: [
            {
              id: 'bw_888',
              chain: 'base',
              address: '0xAb5801a7D398351b8bE11C439e05C5B3259aeC9B',
              created_at: '2023-11-24T21:31:30.515Z',
              updated_at: '2023-11-24T21:31:30.515Z',
            },
          ],
        }.to_json,
        headers: { 'Content-Type' => 'application/json' },
      )

    client = BridgeApi::Client.new(api_key: 'test-key-123', sandbox_mode: true)
    response = client.list_wallets(ending_before: 'bw_999')

    assert response.success?
    assert_equal 200, response.status_code
    refute_nil response.data
    assert_instance_of BridgeApi::ListObject, response.data
    assert_equal 5, response.data.count
    assert_equal 1, response.data.size
    assert_equal 'bw_888', response.data[0].id
    assert_equal 'base', response.data[0].chain
  end

  def test_list_wallets_400_bad_request
    # Mock 400 response for bad request
    stub_request(:get, 'https://api.sandbox.bridge.xyz/v0/wallets').
      to_return(
        status: 400,
        body: {
          code: 'bad_customer_request',
          message: 'fields missing from customer body.',
          source: {
            location: 'query',
            key: 'first_name,ssn',
          },
        }.to_json,
        headers: { 'Content-Type' => 'application/json' },
      )

    client = BridgeApi::Client.new(api_key: 'test-key-123', sandbox_mode: true)
    response = client.list_wallets

    refute response.success?
    assert_equal 400, response.status_code
    assert_instance_of BridgeApi::ApiError, response.error
  end

  def test_list_wallets_401_unauthorized
    # Mock 401 response for unauthorized access
    stub_request(:get, 'https://api.sandbox.bridge.xyz/v0/wallets').
      to_return(
        status: 401,
        body: {
          code: 'required',
          message: 'Missing Api-Key header',
        }.to_json,
      )

    client = BridgeApi::Client.new(api_key: 'invalid-key', sandbox_mode: true)
    response = client.list_wallets

    refute response.success?
    assert_equal 401, response.status_code
    assert_instance_of BridgeApi::AuthenticationError, response.error
  end

  def test_list_wallets_404_not_found
    # Mock 404 response for not found
    stub_request(:get, 'https://api.sandbox.bridge.xyz/v0/wallets').
      to_return(
        status: 404,
        body: {
          code: 'Invalid',
          message: 'Unknown customer id',
        }.to_json,
      )

    client = BridgeApi::Client.new(api_key: 'test-key-123', sandbox_mode: true)
    response = client.list_wallets

    refute response.success?
    assert_equal 404, response.status_code
    assert_instance_of BridgeApi::NotFoundError, response.error
  end

  def test_list_wallets_500_server_error
    # Mock 500 response for server error
    stub_request(:get, 'https://api.sandbox.bridge.xyz/v0/wallets').
      to_return(
        status: 500,
        body: {
          code: 'unexpected',
          message: 'An expected error occurred, you may try again later',
        }.to_json,
        headers: { 'Content-Type' => 'application/json' },
      )

    client = BridgeApi::Client.new(api_key: 'test-key-123', sandbox_mode: true)
    response = client.list_wallets

    refute response.success?
    assert_equal 500, response.status_code
    assert_instance_of BridgeApi::ApiError, response.error
  end

  def test_list_wallets_with_all_parameters
    # Test the list wallets endpoint with all query parameters (limit, starting_after, ending_before)
    stub_request(:get, 'https://api.sandbox.bridge.xyz/v0/wallets').
      with(
        headers: { 'Api-Key' => 'test-key-123' },
        query: { limit: 50, starting_after: 'bw_111', ending_before: 'bw_999' },
      ).
      to_return(
        status: 200,
        body: {
          count: 50,
          data: [
            {
              id: 'bw_555',
              chain: 'solana',
              address: '9kV3ZMehKVyxfHKCcaDLye3P9HHw2MP4jtQa2gKBUmCs',
              created_at: '2023-11-25T21:31:30.515Z',
              updated_at: '2023-11-25T21:31:30.515Z',
            },
            {
              id: 'bw_666',
              chain: 'ethereum',
              address: '0x742d35Cc6634C0532925a3b844Bc454e4438f44e',
              created_at: '2023-11-25T21:32:30.515Z',
              updated_at: '2023-11-25T21:32:30.515Z',
            },
          ],
        }.to_json,
        headers: { 'Content-Type' => 'application/json' },
      )

    client = BridgeApi::Client.new(api_key: 'test-key-123', sandbox_mode: true)
    response = client.list_wallets(limit: 50, starting_after: 'bw_111', ending_before: 'bw_999')

    assert response.success?
    assert_equal 200, response.status_code
    refute_nil response.data
    assert_instance_of BridgeApi::ListObject, response.data
    assert_equal 50, response.data.count
    assert_equal 2, response.data.size
    assert_equal 'bw_555', response.data[0].id
    assert_equal 'solana', response.data[0].chain
    assert_equal 'bw_666', response.data[1].id
    assert_equal 'ethereum', response.data[1].chain
  end
end
