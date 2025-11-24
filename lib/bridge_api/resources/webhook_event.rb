# frozen_string_literal: true
require 'time'

module BridgeApi
  module Resources
    # Represents a Webhook Event
    class WebhookEvent < BaseResource
      OBJECT_NAME = 'webhook_event'

      # Specific accessor methods for convenience
      def api_version
        @values[:api_version]
      end

      def event_id
        @values[:event_id]
      end

      def event_developer_id
        @values[:event_developer_id]
      end

      def event_sequence
        @values[:event_sequence]
      end

      def event_category
        @values[:event_category]
      end

      def event_type
        @values[:event_type]
      end

      def event_object_id
        @values[:event_object_id]
      end

      def event_object_status
        @values[:event_object_status]
      end

      def event_object
        @values[:event_object]
      end

      def event_object_changes
        @values[:event_object_changes]
      end

      def event_created_at
        parse_datetime(@values[:event_created_at])
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
