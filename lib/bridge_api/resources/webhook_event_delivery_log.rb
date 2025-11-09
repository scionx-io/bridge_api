# frozen_string_literal: true
require 'time'

module BridgeApi
  module Resources
    # Represents a Webhook Event Delivery Log
    class WebhookEventDeliveryLog < BaseResource
      OBJECT_NAME = 'webhook_event_delivery_log'

      # Specific accessor methods for convenience
      def status
        @values[:status]
      end

      def event_id
        @values[:event_id]
      end

      def response_body
        @values[:response_body]
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