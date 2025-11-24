# frozen_string_literal: true

require_relative 'base_service'
require_relative '../client'

module BridgeApi
  module Services
    # Service class for handling Webhook-related operations
    class WebhookService < BaseService
      def initialize(client)
        super
        @resource_class = BridgeApi::Webhook
      end

      # Get a webhook by ID
      # @param webhook_id [String] The ID of the webhook
      # @return [BridgeApi::Webhook] The webhook object
      def get(webhook_id)
        @resource_class.retrieve(@client, webhook_id)
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
