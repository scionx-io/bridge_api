# frozen_string_literal: true
require 'time'

module BridgeApi
  module Resources
    # Represents a KYC Link for individual or business verification
    class KycLink < BaseResource
      OBJECT_NAME = 'kyc_link'

      # Class method to create a KYC link
      def self.create(client, params = {})
        # Use the client's automatically generated create method
        client.create_kyc_link(params)
      end

      # Specific accessor methods for convenience
      def id
        @values[:id]
      end

      def full_name
        @values[:full_name]
      end

      def email
        @values[:email]
      end

      def type
        @values[:type]
      end

      def kyc_link
        @values[:kyc_link]
      end

      def tos_link
        @values[:tos_link]
      end

      def kyc_status
        @values[:kyc_status]
      end

      def tos_status
        @values[:tos_status]
      end

      def customer_id
        @values[:customer_id]
      end

      def rejection_reasons
        @values[:rejection_reasons]
      end

      def created_at
        parse_datetime(@values[:created_at])
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