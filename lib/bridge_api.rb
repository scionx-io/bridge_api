# frozen_string_literal: true
require 'httparty'
require 'json'
require 'securerandom'
require_relative 'bridge_api/version'

# Ruby gem for Bridge.xyz API integration
#
# @example Basic usage
#   BridgeApi.config do |c|
#     c.api_key = 'your-api-key'
#     c.sandbox_mode = true
#   end
#
#   client = BridgeApi::Client.new
#   response = client.list_customers
module BridgeApi
  class << self
    # @!attribute [rw] api_key
    #   @return [String, nil] Global API key for Bridge.xyz
    attr_accessor :api_key

    # @!attribute [rw] sandbox_mode
    #   @return [Boolean, nil] Whether to use sandbox environment
    attr_accessor :sandbox_mode

    attr_writer :base_url

    # Configure global settings for Bridge API
    #
    # @yield [self] Configuration block
    # @yieldparam config [BridgeApi] The module to configure
    #
    # @example
    #   BridgeApi.config do |c|
    #     c.api_key = 'your-key'
    #     c.sandbox_mode = true
    #   end
    def config
      yield self
    end

    def base_url
      @base_url || default_base_url
    end

    private

    def default_base_url
      if sandbox_mode
        'https://api.sandbox.bridge.xyz/v0/'
      else
        'https://api.bridge.xyz/v0/'
      end
    end
  end
end

require_relative 'bridge_api/base_resource'
require_relative 'bridge_api/api_resource'
require_relative 'bridge_api/api_operations'
require_relative 'bridge_api/list_object'
require_relative 'bridge_api/util'
require_relative 'bridge_api/resources/wallet'
require_relative 'bridge_api/resources/customer'
require_relative 'bridge_api/resources/transaction_history'
require_relative 'bridge_api/resources/reward_rate'
require_relative 'bridge_api/resources/kyc_link'
require_relative 'bridge_api/resources/webhook'
require_relative 'bridge_api/resources/webhook_event'
require_relative 'bridge_api/resources/webhook_event_delivery_log'
require_relative 'bridge_api/resources/virtual_account'
require_relative 'bridge_api/resources/total_balance'
require_relative 'bridge_api/models/wallets_collection'
require_relative 'bridge_api/client'
