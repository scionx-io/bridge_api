# frozen_string_literal: true

require_relative '../base_resource'
require_relative '../client'

module BridgeApi
  module Services
    # Service class for handling Virtual Account-related operations
    class VirtualAccountService < BaseService
      def initialize(client)
        super(client)
        @resource_class = BridgeApi::VirtualAccount
      end

      # Get a virtual account by ID
      # @param virtual_account_id [String] The ID of the virtual account
      # @return [BridgeApi::VirtualAccount] The virtual account object
      def get(virtual_account_id)
        resource = @resource_class.new(@client)
        resource.retrieve(virtual_account_id)
      end

      # List all virtual accounts
      # @param options [Hash] Optional parameters for filtering
      # @return [Array<BridgeApi::VirtualAccount>] Array of virtual account objects
      def list(options = {})
        @resource_class.list(@client, options)
      end
    end
  end
end