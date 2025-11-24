# frozen_string_literal: true

module BridgeApi
  module Services
    # Service class for handling Wallet-related operations
    class WalletService < BaseService
      def initialize(client)
        super
        @resource_class = BridgeApi::Wallet
      end

      # Get a wallet by ID
      # @param wallet_id [String] The ID of the wallet
      # @return [BridgeApi::Wallet] The wallet object
      def get(wallet_id)
        resource = @resource_class.new(@client)
        resource.retrieve(wallet_id)
      end

      # List all wallets
      # @param options [Hash] Optional parameters for filtering
      # @return [Array<BridgeApi::Wallet>] Array of wallet objects
      def list(options = {})
        @resource_class.list(@client, options)
      end
    end
  end
end
