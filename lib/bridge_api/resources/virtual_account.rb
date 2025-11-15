# frozen_string_literal: true
require 'time'

module BridgeApi
  module Resources
    # Represents a Bridge Virtual Account resource
    class VirtualAccount < APIResource
      OBJECT_NAME = 'virtual_account'

      def self.resource_path
        '/virtual_accounts'
      end

      # Include the operations this resource supports
      # VirtualAccounts don't support standard list/create/retrieve/delete directly
      # They are accessed through customer endpoints, so we won't include the standard operations here

      def initialize(attributes = {})
        super
      end

      # Specific accessor methods for convenience
      def id
        @values[:id]
      end

      def status
        @values[:status]
      end

      def developer_fee_percent
        @values[:developer_fee_percent]
      end

      def customer_id
        @values[:customer_id]
      end

      def created_at
        parse_datetime(@values[:created_at])
      end

      def source_deposit_instructions
        @values[:source_deposit_instructions]
      end

      def destination
        @values[:destination]
      end

      def balances
        @values[:balances] || []
      end

      # Dynamic method handling for all attributes in @values
      def method_missing(method_name, *args)
        if @values.key?(method_name)
          @values[method_name]
        else
          super
        end
      end

      def respond_to_missing?(method_name, include_private = false)
        @values.key?(method_name) || super
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
