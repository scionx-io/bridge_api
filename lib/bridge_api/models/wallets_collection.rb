# frozen_string_literal: true

module BridgeApi
  module Models
    # Represents a collection of Bridge Wallets with pagination metadata
    class WalletsCollection
      attr_reader :data, :count, :has_more

      # Initialize a WalletsCollection object from API response data
      # @param [Hash] response The API response hash
      def initialize(response = {})
        @count = response['count']&.to_i
        @data = parse_wallets(response['data'] || [])
      end

      # Check if the collection is empty
      # @return [Boolean] True if the collection has no wallets
      def empty?
        @data.empty?
      end

      # Get the number of wallets in the collection
      # @return [Integer] The number of wallets
      def size
        @data.length
      end

      # Alias for size
      # @return [Integer] The number of wallets
      def length
        size
      end

      # Support array-like access
      # @param [Integer] index The index to access
      def [](index)
        @data[index]
      end

      # Make the collection enumerable to support iteration
      include Enumerable

      def each(&block)
        @data.each(&block)
      end

      private

      # Parse an array of wallet hashes into Wallet objects
      # @param [Array<Hash>] wallet_hashes Array of wallet data from API
      # @return [Array<Wallet>] Array of Wallet objects
      def parse_wallets(wallet_hashes)
        wallet_hashes.map { |wallet_hash| Wallet.new(wallet_hash) }
      end
    end
  end
end
