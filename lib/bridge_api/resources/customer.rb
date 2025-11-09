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

      def self.get_customer_wallets(client, customer_id, params = {})
        # Use the client's public API to make the request
        client.get_customer_wallets(customer_id, params)
      end

      def self.create_wallet_for_customer(client, customer_id, chain, idempotency_key: nil)
        # Use the client's public API to make the request
        client.create_customer_wallet(customer_id, chain, idempotency_key: idempotency_key)
      end

      def self.get_customer_wallet(client, customer_id, wallet_id)
        # Use the client's public API to make the request
        client.get_customer_wallet(customer_id, wallet_id)
      end

      def self.get_customer_virtual_accounts(client, customer_id, params = {})
        # Use the client's public API to make the request
        client.list_customer_virtual_accounts(customer_id, params)
      end

      def self.get_customer_virtual_account(client, customer_id, virtual_account_id)
        # Use the client's public API to make the request
        client.get_customer_virtual_account(customer_id, virtual_account_id)
      end

      def self.create_customer_virtual_account(client, customer_id, params, idempotency_key: nil)
        # Use the client's public API to make the request
        client.create_customer_virtual_account(customer_id, params, idempotency_key: idempotency_key)
      end

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

      def wallets(client, params = {})
        self.class.get_customer_wallets(client, id, params)
      end

      def create_wallet(client, chain, idempotency_key: nil)
        self.class.create_wallet_for_customer(client, id, chain, idempotency_key: idempotency_key)
      end

      def get_wallet(client, wallet_id)
        self.class.get_customer_wallet(client, id, wallet_id)
      end

      def virtual_accounts(client, params = {})
        self.class.get_customer_virtual_accounts(client, id, params)
      end

      def get_virtual_account(client, virtual_account_id)
        self.class.get_customer_virtual_account(client, id, virtual_account_id)
      end

      def create_virtual_account(client, params, idempotency_key: nil)
        self.class.create_customer_virtual_account(client, id, params, idempotency_key: idempotency_key)
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
