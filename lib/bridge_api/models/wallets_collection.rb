# frozen_string_literal: true

module BridgeApi
  module Models
    # Represents a collection of Bridge Wallets with pagination metadata
    # This is maintained for backward compatibility with the existing implementation
    class WalletsCollection
      attr_reader :data, :count

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

      def each(&)
        @data.each(&)
      end

      private

      def parse_wallets(wallet_hashes)
        wallet_hashes.map do |wallet_hash|
          if wallet_hash.is_a?(Hash)
            BridgeApi::Resources::Wallet.new(wallet_hash)
          else
            wallet_hash
          end
        end
      end
    end
  end
end
