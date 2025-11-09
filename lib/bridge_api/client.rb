# frozen_string_literal: true
module BridgeApi
  class Client
    include HTTParty

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
      raise ArgumentError, 'API key must be provided' unless @api_key&.strip&.length&.positive?

      @base_url = sandbox_mode ? 'https://api.sandbox.bridge.xyz/v0' : 'https://api.bridge.xyz/v0'
      configure_client
    end

    # Dynamically define CRUD methods for resources
    RESOURCES.each do |resource|
      singular = resource.to_s.sub(/s$/, '')

      define_method("list_#{resource}") { |params = {}| request(:get, resource.to_s, params) }
      define_method("get_#{singular}") { |id| request(:get, "#{resource}/#{id}") }
      define_method("create_#{singular}") { |payload| request(:post, resource.to_s, payload) }
    end

    READ_ONLY_RESOURCES.each do |resource|
      define_method("get_#{resource}") { |params = {}| request(:get, resource.to_s, params) }
    end

    def get_exchange_rates(params = {})
      request(:get, 'exchange_rates', params)
    end



    private

    def configure_client
      self.class.base_uri(@base_url)
      self.class.headers(
        'Api-Key' => @api_key,
        'Content-Type' => 'application/json',
        'User-Agent' => 'BridgeApi Ruby Gem',
      )
      self.class.default_timeout(30)
    end

    def request(method, endpoint, payload = {}, retries = 0)
      options = {}
      if %i[get delete].include?(method)
        options[:query] = payload unless payload.empty?
      else
        options[:body] = payload.to_json unless payload.empty?
        options[:headers] ||= {}
        options[:headers]['Idempotency-Key'] = SecureRandom.uuid if method == :post
      end

      response = self.class.send(method, "/#{endpoint}", options)

      if response.code == 429 && retries < MAX_RETRIES
        sleep_time = response.headers['Retry-After']&.to_i || 1
        sleep(sleep_time)
        return request(method, endpoint, payload, retries + 1)
      end

      handle_response(response)
    end

    def handle_response(response)
      case response.code
      when 200..299
        Response.new(response.code, response.parsed_response, nil)
      when 400 then Response.new(response.code, nil,
                                 ApiError.new(response.parsed_response&.dig('message') || 'Bad request'))
      when 401 then Response.new(response.code, nil, AuthenticationError.new('Invalid API key'))
      when 403 then Response.new(response.code, nil, ForbiddenError.new(response.parsed_response&.dig('message')))
      when 404 then Response.new(response.code, nil, NotFoundError.new('Resource not found'))
      when 429 then Response.new(response.code, nil, RateLimitError.new(response.headers['X-RateLimit-Reset']))
      when 503 then Response.new(response.code, nil, ServiceUnavailableError.new('Service temporarily unavailable'))
      else Response.new(response.code, nil,
                        ApiError.new(response.parsed_response&.dig('message') || 'API request failed'))
      end
    end
  end

  class Response
    attr_reader :status_code, :data, :error

    def initialize(status_code, data, error)
      @status_code = status_code
      @data = data
      @error = error
    end

    def success?
      @error.nil?
    end
  end

  # Errors
  class ApiError < StandardError; end
  class AuthenticationError < ApiError; end
  class RateLimitError < ApiError; end
  class ForbiddenError < ApiError; end
  class NotFoundError < ApiError; end
  class ServiceUnavailableError < ApiError; end
end
