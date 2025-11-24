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
    end
  end
end
