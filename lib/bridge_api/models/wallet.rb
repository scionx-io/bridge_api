# frozen_string_literal: true
require 'time'

module BridgeApi
  module Models
    # Represents a Bridge Wallet resource
    class Wallet
      attr_reader :id, :chain, :address, :created_at, :updated_at

      # Initialize a Wallet object from API response data
      # @param [Hash] attributes The attributes from the API response
      def initialize(attributes = {})
        @id = attributes['id']
        @chain = attributes['chain']
        @address = attributes['address']
        @created_at = parse_datetime(attributes['created_at'])
        @updated_at = parse_datetime(attributes['updated_at'])
      end

      # Convert the Wallet object back to a hash representation
      # @return [Hash] The hash representation of the wallet
      def to_h
        {
          id: @id,
          chain: @chain,
          address: @address,
          created_at: @created_at&.iso8601,
          updated_at: @updated_at&.iso8601,
        }
      end

      # Convert the Wallet object to JSON
      # @return [String] The JSON representation of the wallet
      def to_json(*args)
        to_h.to_json(*args)
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
