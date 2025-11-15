# frozen_string_literal: true

require_relative '../base_resource'
require_relative '../client'

module BridgeApi
  module Services
    # Service class for handling External Account-related operations
    class ExternalAccountService < BaseService
      def initialize(client)
        super(client)
        @resource_class = BridgeApi::ExternalAccount
      end

      # Get an external account by ID
      # @param external_account_id [String] The ID of the external account
      # @return [BridgeApi::ExternalAccount] The external account object
      def get(external_account_id)
        resource = @resource_class.new(@client)
        resource.retrieve(external_account_id)
      end

      # List all external accounts
      # @param options [Hash] Optional parameters for filtering
      # @return [Array<BridgeApi::ExternalAccount>] Array of external account objects
      def list(options = {})
        @resource_class.list(@client, options)
      end
    end
  end
end