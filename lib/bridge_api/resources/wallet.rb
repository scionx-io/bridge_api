# frozen_string_literal: true
require 'time'

module BridgeApi
  module Resources
    # Represents a Bridge Wallet resource
    class Wallet < APIResource
      OBJECT_NAME = 'wallet'

      def self.resource_path
        '/wallets'
      end

      # Include the operations this resource supports
      include BridgeApi::APIOperations::List
      include BridgeApi::APIOperations::Retrieve
      include BridgeApi::APIOperations::Create

      def self.get_history(client, wallet_id, params = {})
        # Use the client's public API to make the request
        client.get_wallet_history(wallet_id, params)
      end

      def initialize(attributes = {})
        super
      end

      # Specific accessor methods for convenience
      def id
        @values[:id]
      end

      def chain
        @values[:chain]
      end

      def address
        @values[:address]
      end

      def created_at
        parse_datetime(@values[:created_at])
      end

      def updated_at
        parse_datetime(@values[:updated_at])
      end

      # Get transaction history for this wallet
      def history(client, params = {})
        self.class.get_history(client, id, params)
      end

      def self.get_for_customer(client, customer_id, wallet_id)
        client.get_customer_wallet(customer_id, wallet_id)
      end


      private

      # Parse a datetime string to a Time object
      # @param [String, nil] datetime_string The datetime string to parse
      # @return [Time, nil] The parsed Time object or nil if input is nil
      def parse_datetime(datetime_string)
        return nil unless datetime_string

        Time.parse(datetime_string)
      rescue ArgumentError
        nil
      end
    end
  end
end
