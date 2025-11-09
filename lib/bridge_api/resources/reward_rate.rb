# frozen_string_literal: true
require 'time'

module BridgeApi
  module Resources
    # Represents a reward rate for a given stablecoin
    class RewardRate < BaseResource
      OBJECT_NAME = 'reward_rate'

      # Specific accessor methods for convenience
      def rate
        @values[:rate]
      end

      def effective_at
        parse_datetime(@values[:effective_at])
      end

      def expires_at
        parse_datetime(@values[:expires_at])
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
