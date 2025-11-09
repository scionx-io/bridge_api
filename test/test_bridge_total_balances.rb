# frozen_string_literal: true

# Coverage reporting
require 'simplecov'
SimpleCov.start do
  add_filter '/test/'
end

require 'minitest/autorun'
require 'webmock/minitest'
require_relative '../lib/bridge_api'

class BridgeTotalBalancesTest < Minitest::Test
  def setup
    # Reset global configuration before each test
    BridgeApi.api_key = nil
    BridgeApi.sandbox_mode = nil
  end

  def test_get_wallet_total_balances_success
    # Mock the successful API response for getting total balances
    stub_request(:get, 'https://api.sandbox.bridge.xyz/v0/wallets/total_balances').
      with(headers: { 'Api-Key' => 'test-key-123' }).
      to_return(
        status: 200,
        body: [
          {
            balance: '100.25',
            currency: 'usdb',
            chain: 'solana',
            contract_address: 'ENL66PGy8d8j5KNqLtCcg4uidDUac5ibt45wbjH9REzB',
          },
          {
            balance: '50.75',
            currency: 'usdc',
            chain: 'ethereum',
            contract_address: nil,
          },
        ].to_json,
        headers: { 'Content-Type' => 'application/json' },
      )

    client = BridgeApi::Client.new(api_key: 'test-key-123', sandbox_mode: true)
    balances = client.get_wallet_total_balances

    assert balances.success?
    assert_equal 200, balances.status_code
    refute_nil balances.data
    assert_instance_of Array, balances.data
    assert_equal 2, balances.data.length

    first_balance = balances.data[0]
    assert_instance_of BridgeApi::Resources::TotalBalance, first_balance
    assert_equal '100.25', first_balance.balance
    assert_equal 'usdb', first_balance.currency
    assert_equal 'solana', first_balance.chain
    assert_equal 'ENL66PGy8d8j5KNqLtCcg4uidDUac5ibt45wbjH9REzB', first_balance.contract_address

    second_balance = balances.data[1]
    assert_instance_of BridgeApi::Resources::TotalBalance, second_balance
    assert_equal '50.75', second_balance.balance
    assert_equal 'usdc', second_balance.currency
    assert_equal 'ethereum', second_balance.chain
    assert_nil second_balance.contract_address
  end

  def test_get_wallet_total_balances_401_unauthorized
    # Mock 401 response for unauthorized access
    stub_request(:get, 'https://api.sandbox.bridge.xyz/v0/wallets/total_balances').
      to_return(
        status: 401,
        body: {
          code: 'required',
          message: 'Missing Api-Key header',
        }.to_json,
      )

    client = BridgeApi::Client.new(api_key: 'invalid-key', sandbox_mode: true)
    response = client.get_wallet_total_balances

    refute response.success?
    assert_equal 401, response.status_code
    assert_instance_of BridgeApi::AuthenticationError, response.error
  end

  def test_get_wallet_total_balances_404_not_found
    # Mock 404 response for not found
    stub_request(:get, 'https://api.sandbox.bridge.xyz/v0/wallets/total_balances').
      to_return(
        status: 404,
        body: {
          code: 'Invalid',
          message: 'Unknown endpoint',
        }.to_json,
      )

    client = BridgeApi::Client.new(api_key: 'test-key-123', sandbox_mode: true)
    response = client.get_wallet_total_balances

    refute response.success?
    assert_equal 404, response.status_code
    assert_instance_of BridgeApi::NotFoundError, response.error
  end
end
