# frozen_string_literal: true
require 'minitest/autorun'
require_relative '../lib/bridge_api'

class BridgeApiTest < Minitest::Test
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
end
