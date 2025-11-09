# frozen_string_literal: true

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
    end

    # --- Dynamic Endpoints ---
    (RESOURCES + READ_ONLY_RESOURCES).each do |resource|
      singular = resource.to_s.sub(/s$/, '')

      define_method("list_#{resource}") { |params = {}| request(:get, resource, params) }
      define_method("get_#{singular}")  { |id| request(:get, "#{resource}/#{id}") }

      # Special case: add method to get wallet history
      if resource == :wallets
        define_method('get_wallet_history') do |wallet_id, params = {}|
          request(:get, "wallets/#{wallet_id}/history", params)
        end
      end

      # Special case: add method to get customer wallets
      if resource == :customers
        define_method('get_customer_wallets') do |customer_id, params = {}|
          request(:get, "customers/#{customer_id}/wallets", params)
        end
      end

      next if READ_ONLY_RESOURCES.include?(resource)

      define_method("create_#{singular}") do |payload|
        request(:post, resource, payload)
      end
    end

    # --- Special Endpoints ---
    def get_exchange_rates(params = {})
      request(:get, 'exchange_rates', params)
    end

    def get_wallet_total_balances
      response = request(:get, 'wallets/total_balances')
      return response unless response.success? && response.data.is_a?(Array)

      converted = response.data.map { |item| BridgeApi::Resources::TotalBalance.new(item) }
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

    def build_request_options(method, payload)
      return { query: payload } if %i[get delete].include?(method)

      {
        body: payload.to_json,
        headers: { 'Idempotency-Key' => SecureRandom.uuid },
      }
    end

    def retry_request(method, endpoint, payload, retries, response)
      sleep(response.headers['Retry-After']&.to_i || 1)
      request(method, endpoint, payload, retries + 1)
    end

    def handle_response(response)
      status = response.code
      request_path = response.request.path
      data = if (200..299).cover?(status)
               hint = determine_resource_hint_from_endpoint(request_path)
               BridgeApi::Util.convert_to_bridged_object(
                 response.parsed_response,
                 resource_hint: hint,
               )
             end
      error = data.nil? ? build_error(status, response) : nil
      Response.new(status, data, error)
    end

    def determine_resource_hint_from_endpoint(path)
      path_string = path.is_a?(URI) ? path.to_s : path
      path_parts = path_string.split('/').reject(&:empty?)

      return nil if path_parts.empty?

      resource_name = extract_resource_name(path_parts)
      resource_name = resource_name.chomp('s') if resource_name

      map_resource_to_hint(resource_name)
    end

    def extract_resource_name(parts)
      case parts.length
      when 1
        parts.last
      when 2
        extract_from_two_parts(parts)
      else
        extract_from_three_or_more_parts(parts)
      end
    end

    def extract_from_two_parts(parts)
      first, second = parts
      return parts.last unless valid_resource?(first) && looks_like_id?(second)

      first
    end

    def extract_from_three_or_more_parts(parts)
      first, second, third = parts
      return first unless valid_resource?(first) && looks_like_id?(second)

      third
    end

    def valid_resource?(name)
      name&.match?(/[a-z]+/)
    end

    def looks_like_id?(value)
      value&.match?(/^[a-zA-Z0-9_]+$/)
    end

    def map_resource_to_hint(resource_name)
      {
        'wallet' => 'wallet',
        'customer' => 'customer',
        'history' => 'transaction_history',
      }[resource_name]
    end

    def build_error(status, response)
      parsed_response = response.parsed_response
      if parsed_response.is_a?(Hash)
        msg = parsed_response['message']
      elsif parsed_response.is_a?(String)
        begin
          json_response = JSON.parse(parsed_response)
          msg = json_response.is_a?(Hash) ? json_response['message'] : nil
        rescue JSON::ParserError
          msg = nil
        end
      else
        msg = nil
      end

      case status
      when 400 then ApiError.new(msg || 'Bad request')
      when 401 then AuthenticationError.new('Invalid API key')
      when 403 then ForbiddenError.new(msg || 'Forbidden')
      when 404 then NotFoundError.new('Resource not found')
      when 429 then RateLimitError.new(response.headers['X-RateLimit-Reset'])
      when 503 then ServiceUnavailableError.new('Service temporarily unavailable')
      else ApiError.new(msg || 'API request failed')
      end
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

  # --- Errors ---
  class ApiError < StandardError; end
  class AuthenticationError < ApiError; end
  class RateLimitError < ApiError; end
  class ForbiddenError < ApiError; end
  class NotFoundError < ApiError; end
  class ServiceUnavailableError < ApiError; end
end
