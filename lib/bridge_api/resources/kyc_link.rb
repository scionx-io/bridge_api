# frozen_string_literal: true
require 'time'

module BridgeApi
  module Resources
    # Represents a KYC Link for individual or business verification
    class KycLink < APIResource
      OBJECT_NAME = 'kyc_link'

      def self.resource_path
        '/kyc_links'
      end

      # Include the operations this resource supports
      include BridgeApi::APIOperations::Create

      # Class method to get a specific KYC link by ID
      def self.retrieve(client, id, params = {})
        client.get_kyc_link(id)
      end

      # Class method to list all KYC links
      def self.list(client, params = {})
        client.list_kyc_links(params)
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
