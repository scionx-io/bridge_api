# frozen_string_literal: true
require 'json'

module BridgeApi
  module Resources
    # Represents a Bridge Wallet Total Balance - a specialized object returned by wallet operations
    class TotalBalance < BaseResource
      def initialize(attributes = {})
        super
      end

      # Specific accessor methods for convenience
      def balance
        @values[:balance]
      end

      def currency
        @values[:currency]
      end

      def chain
        @values[:chain]
      end

      def contract_address
        @values[:contract_address]
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
    end
  end
end
