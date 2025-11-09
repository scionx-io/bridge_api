# frozen_string_literal: true
require 'time'

module BridgeApi
  module Resources
    # Represents a Bridge Customer resource
    class Customer < APIResource
      OBJECT_NAME = 'customer'

      def self.resource_path
        '/customers'
      end

      # Include the operations this resource supports
      include BridgeApi::APIOperations::List
      include BridgeApi::APIOperations::Retrieve
      include BridgeApi::APIOperations::Create
      include BridgeApi::APIOperations::Update
      include BridgeApi::APIOperations::Delete

      def initialize(attributes = {})
        super
      end

      # Specific accessor methods for convenience
      def id
        @values[:id]
      end

      def email
        @values[:email]
      end

      def first_name
        @values[:first_name]
      end

      def last_name
        @values[:last_name]
      end

      def created_at
        parse_datetime(@values[:created_at])
      end

      def updated_at
        parse_datetime(@values[:updated_at])
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
