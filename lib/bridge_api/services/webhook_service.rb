# frozen_string_literal: true

require_relative '../base_resource'
require_relative '../client'

module BridgeApi
  module Services
    # Service class for handling Webhook-related operations
    class WebhookService < BaseService
      def initialize(client)
        super(client)
        @resource_class = BridgeApi::Webhook
      end

      # Get a webhook by ID
      # @param webhook_id [String] The ID of the webhook
      # @return [BridgeApi::Webhook] The webhook object
      def get(webhook_id)
        resource = @resource_class.new(@client)
        resource.retrieve(webhook_id)
      end

      # List all webhooks
      # @param options [Hash] Optional parameters for filtering
      # @return [Array<BridgeApi::Webhook>] Array of webhook objects
      def list(options = {})
        @resource_class.list(@client, options)
      end
    end
  end
end