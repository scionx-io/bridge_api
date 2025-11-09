# frozen_string_literal: true
require 'time'

module BridgeApi
  module Resources
    # Represents a transaction history item for a Bridge Wallet
    class TransactionHistory < BaseResource
      OBJECT_NAME = 'transaction_history'

      # Specific accessor methods for convenience
      def amount
        @values[:amount]
      end

      def developer_fee
        @values[:developer_fee]
      end

      def created_at
        parse_datetime(@values[:created_at])
      end

      def updated_at
        parse_datetime(@values[:updated_at])
      end

      def customer_id
        @values[:customer_id]
      end

      def source
        @values[:source]
      end

      def destination
        @values[:destination]
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
