# frozen_string_literal: true

require 'httparty'
require 'securerandom'
require 'json'

module BridgeApi
  class Client
    include HTTParty

    BASE_URLS = {
      sandbox: 'https://api.sandbox.bridge.xyz/v0',
      production: 'https://api.bridge.xyz/v0',
    }.freeze

    RESOURCES = %i[
      kyc_links wallets customers transfers external_accounts virtual_accounts
      cards prefunded_accounts liquidation_addresses static_memos
      batch_settlements funds_requests webhooks crypto_return_policies rewards
      developers
    ].freeze

    READ_ONLY_RESOURCES = %i[lists].freeze
    MAX_RETRIES = 3

    def initialize(api_key: nil, sandbox_mode: true)
      @api_key = api_key || BridgeApi.api_key
      raise ArgumentError, 'API key must be provided' if @api_key.to_s.strip.empty?

      @base_url = sandbox_mode ? BASE_URLS[:sandbox] : BASE_URLS[:production]
      configure_client

      self.class.define_dynamic_resource_methods
    end

    # --- Special Endpoints ---
    def get_exchange_rates(params = {})
      request(:get, 'exchange_rates', params)
    end

    def get_wallet_total_balances
      response = request(:get, 'wallets/total_balances')
      return response unless response.success? && response.data.is_a?(Array)

      converted = response.data.map do |item|
        BridgeApi::Resources::TotalBalance.new(item)
      end

      Response.new(response.status_code, converted, nil)
    end

    private

    def configure_client
      self.class.base_uri(@base_url)
      self.class.headers(
        'Api-Key' => @api_key,
        'Content-Type' => 'application/json',
        'User-Agent' => 'BridgeApi Ruby Client',
      )
      self.class.default_timeout(30)
    end

    def request(method, endpoint, payload = {}, retries = 0)
      options = build_request_options(method, payload)
      response = self.class.send(method, "/#{endpoint}", options)

      if response.code == 429 && retries < MAX_RETRIES
        return retry_request(method, endpoint, payload, retries,
                             response)
      end

      handle_response(response)
    end

    def build_request_options(method, payload, idempotency_key: nil)
      if %i[get delete].include?(method)
        { query: payload }
      else
        # Only add Idempotency-Key if explicitly provided or for POST/PATCH
        # PUT requests (like webhook updates) don't support idempotency keys
        headers = {}
        if idempotency_key || %i[post patch].include?(method)
          headers['Idempotency-Key'] = idempotency_key || SecureRandom.uuid
        end
        { body: payload.to_json, headers: headers }
      end
    end

    def request_with_idempotency(method, endpoint, payload, idempotency_key)
      options = build_request_options(method, payload, idempotency_key: idempotency_key)
      handle_response(self.class.send(method, "/#{endpoint}", options))
    end

    def retry_request(method, endpoint, payload, retries, response)
      sleep(response.headers['Retry-After']&.to_i || 1)
      request(method, endpoint, payload, retries + 1)
    end

    # --- Resource Accessor Support ---
    class ResourceAccessor
      def initialize(client, resource_name)
        @client = client
        @resource_name = resource_name
        @singular_resource_name = resource_name.to_s.sub(/s$/, '')
      end

      def list(params = {})
        @client.send("list_#{@resource_name}", params)
      end

      def get(id)
        @client.send("get_#{@singular_resource_name}", id)
      end

      def retrieve(id)
        @client.send("get_#{@singular_resource_name}", id)
      end

      def create(params = {}, idempotency_key: nil)
        method_name = idempotency_key ? "create_#{@singular_resource_name}_with_idempotency" : "create_#{@singular_resource_name}"
        if @client.respond_to?(method_name)
          @client.send(method_name, params, idempotency_key: idempotency_key)
        else
          @client.send(:request, :post, @resource_name, params)
        end
      end

      def update(id, params = {}, idempotency_key: nil)
        method_name = idempotency_key ? "update_#{@singular_resource_name}_with_idempotency" : "update_#{@singular_resource_name}"
        if @client.respond_to?(method_name)
          @client.send(method_name, id, params, idempotency_key: idempotency_key)
        else
          # Use PUT for webhooks, PATCH for others
          http_method = @resource_name == :webhooks ? :put : :patch
          @client.send(:request, http_method, "#{@resource_name}/#{id}", params)
        end
      end

      def delete(id)
        method_name = "delete_#{@singular_resource_name}"
        if @client.respond_to?(method_name)
          @client.send(method_name, id)
        else
          @client.send(:request, :delete, "#{@resource_name}/#{id}", {})
        end
      end

      private

      def method_missing(method_name, *args, &block)
        # Delegate other methods to the client that start with the resource name
        if @client.respond_to?(method_name)
          @client.send(method_name, *args)
        else
          super
        end
      end

      def respond_to_missing?(method_name, include_private = false)
        @client.respond_to?(method_name) || super
      end
    end

    # --- Class Methods ---
    class << self
      def define_dynamic_resource_methods
        (RESOURCES + READ_ONLY_RESOURCES).each do |resource|
          define_resource_methods(resource)
          define_resource_accessor(resource)
        end
      end

      private

      def define_resource_methods(resource)
        singular = resource.to_s.sub(/s$/, '')

        define_method("list_#{resource}") { |params = {}| request(:get, resource, params) }
        define_method("get_#{singular}") { |id| request(:get, "#{resource}/#{id}") }

        define_special_methods(resource) unless READ_ONLY_RESOURCES.include?(resource)
      end

      def define_resource_accessor(resource)
        define_method(resource) do
          instance_variable_name = "@#{resource}_accessor"
          unless instance_variable_defined?(instance_variable_name)
            instance_variable_set(instance_variable_name, ResourceAccessor.new(self, resource))
          end
          instance_variable_get(instance_variable_name)
        end
      end

      def define_special_methods(resource)
        send("define_#{resource}_methods") if respond_to?("define_#{resource}_methods", true)
      end

      # --- Define resource-specific helpers ---
      def define_wallets_methods
        define_method('get_wallet_history') do |wallet_id, params = {}|
          request(:get, "wallets/#{wallet_id}/history", params)
        end
      end

      def define_customers_wallet_methods
        define_method('get_customer_wallets') do |customer_id, params = {}|
          request(:get, "customers/#{customer_id}/wallets", params)
        end

        define_method('get_customer_wallet') do |customer_id, wallet_id|
          request(:get, "customers/#{customer_id}/wallets/#{wallet_id}")
        end

        define_method('create_customer_wallet') do |customer_id, chain, idempotency_key: nil|
          payload = { chain: chain }
          request_with_idempotency(:post, "customers/#{customer_id}/wallets", payload, idempotency_key)
        end
      end

      def define_customers_virtual_account_methods
        define_method('list_customer_virtual_accounts') do |customer_id, params = {}|
          request(:get, "customers/#{customer_id}/virtual_accounts", params)
        end

        define_method('get_customer_virtual_account') do |customer_id, virtual_account_id|
          request(:get, "customers/#{customer_id}/virtual_accounts/#{virtual_account_id}")
        end

        define_method('create_customer_virtual_account') do |customer_id, params, idempotency_key: nil|
          request_with_idempotency(
            :post,
            "customers/#{customer_id}/virtual_accounts",
            params,
            idempotency_key,
          )
        end

        define_method('update_customer_virtual_account') do |customer_id,
                                                             virtual_account_id,
                                                             params,
                                                             idempotency_key: nil|
          request_with_idempotency(
            :put,
            "customers/#{customer_id}/virtual_accounts/#{virtual_account_id}",
            params,
            idempotency_key,
          )
        end

        define_method('deactivate_customer_virtual_account') do |customer_id, virtual_account_id, idempotency_key: nil|
          request_with_idempotency(
            :post,
            "customers/#{customer_id}/virtual_accounts/#{virtual_account_id}/deactivate",
            {},
            idempotency_key,
          )
        end

        define_method('reactivate_customer_virtual_account') do |customer_id, virtual_account_id, idempotency_key: nil|
          request_with_idempotency(
            :post,
            "customers/#{customer_id}/virtual_accounts/#{virtual_account_id}/reactivate",
            {},
            idempotency_key,
          )
        end
      end

      def define_customers_methods
        define_customers_wallet_methods
        define_customers_virtual_account_methods
      end

      def define_webhooks_methods
        define_method('get_webhook_events') { |webhook_id| request(:get, "webhooks/#{webhook_id}/events") }
        define_method('get_webhook_logs') { |webhook_id| request(:get, "webhooks/#{webhook_id}/logs") }
        define_method('send_webhook_event') do |webhook_id, event_id, idempotency_key: nil|
          payload = { event_id: event_id }
          request_with_idempotency(:post, "webhooks/#{webhook_id}/send", payload, idempotency_key)
        end
      end

      private :define_resource_methods, :define_special_methods, :define_resource_accessor,
              :define_wallets_methods, :define_customers_methods,
              :define_customers_wallet_methods, :define_customers_virtual_account_methods,
              :define_webhooks_methods
    end

    # --- Response Handling ---
    def handle_response(response)
      status = response.code
      raw_data = (200..299).cover?(status) ? response.parsed_response : nil
      data = raw_data ? BridgeApi::Util.convert_to_bridged_object(raw_data) : raw_data
      error = data.nil? ? build_error(status, response) : nil
      Response.new(status, data, error)
    end

    def build_error(status, response)
      msg = response.parsed_response.is_a?(Hash) ? response.parsed_response['message'] : nil

      case status
      when 400 then BridgeApi::ApiError.new(msg || 'Bad request')
      when 401 then BridgeApi::AuthenticationError.new('Invalid API key')
      when 403 then BridgeApi::ForbiddenError.new(msg || 'Forbidden')
      when 404 then BridgeApi::NotFoundError.new('Resource not found')
      when 429 then BridgeApi::RateLimitError.new(response.headers['X-RateLimit-Reset'])
      when 503 then BridgeApi::ServiceUnavailableError.new('Service temporarily unavailable')
      else BridgeApi::ApiError.new(msg || 'API request failed')
      end
    end

    # --- Response Wrapper ---
    class Response
      attr_reader :status_code, :data, :error

      def initialize(status_code, data, error)
        @status_code = status_code
        @data = data
        @error = error
      end

      def success? = @error.nil?
    end
  end

  # --- Errors ---
  class ApiError < StandardError; end
  class AuthenticationError < ApiError; end
  class RateLimitError < ApiError; end
  class ForbiddenError < ApiError; end
  class NotFoundError < ApiError; end
  class ServiceUnavailableError < ApiError; end
end
