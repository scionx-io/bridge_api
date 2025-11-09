# frozen_string_literal: true
require 'time'

module BridgeApi
  module Resources
    # Represents a Webhook endpoint
    class Webhook < APIResource
      OBJECT_NAME = 'webhook'

      def self.resource_path
        '/webhooks'
      end

      # Class methods for API operations
      def self.list(client, params = {})
        client.list_webhooks(params)
      end

      def self.retrieve(client, id, _params = {})
        client.get_webhook(id)
      end

      def self.create(client, params = {})
        client.create_webhook(params)
      end

      # Specific accessor methods for convenience
      def id
        @values[:id]
      end

      def url
        @values[:url]
      end

      def status
        @values[:status]
      end

      def public_key
        @values[:public_key]
      end

      def event_categories
        @values[:event_categories] || []
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
