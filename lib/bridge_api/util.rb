# frozen_string_literal: true
require 'net/http'
require 'json'
require_relative 'list_object'
require_relative 'resources/wallet'
require_relative 'resources/customer'
module BridgeApi
  class Client
    attr_reader :api_key, :base_url

    def initialize(api_key:, base_url: 'https://api.bridgeapi.io')
      @api_key = api_key
      @base_url = base_url
    end

    def get(path, params = {})
      uri = URI.join(base_url, path)
      uri.query = URI.encode_www_form(params) if params.any?
      request = Net::HTTP::Get.new(uri)
      perform_request(request)
    end

    def post(path, body = {})
      uri = URI.join(base_url, path)
      request = Net::HTTP::Post.new(uri)
      request.body = body.to_json
      perform_request(request)
    end

    def delete(path)
      uri = URI.join(base_url, path)
      request = Net::HTTP::Delete.new(uri)
      perform_request(request)
    end

    def perform_request(request)
      request['Authorization'] = "Bearer #{api_key}"
      request['Content-Type'] = 'application/json'
      http = Net::HTTP.new(request.uri.host, request.uri.port)
      http.use_ssl = request.uri.scheme == 'https'
      response = http.request(request)
      handle_response(response)
    end

    def handle_response(response)
      parsed_body = begin
        JSON.parse(response.body)
      rescue StandardError
        {}
      end
      request_path = response.request.path
      resource_hint = determine_resource_hint_from_endpoint(request_path)
      converted = BridgeApi::Util.convert_to_bridged_object(
        parsed_body,
        resource_hint: resource_hint,
      )
      case response
      when Net::HTTPSuccess
        converted
      else
        raise ApiError.new("Bridge API error: #{response.code}", converted)
      end
    end

    private

    def determine_resource_hint_from_endpoint(path)
      path_parts = path.split('/').reject(&:empty?)
      return unless path_parts.length >= 2

      first_part = path_parts[0]
      second_part = path_parts[1]

      return unless first_part.match?(/[a-z]+/)
      return unless second_part.match?(/^[a-zA-Z0-9_]+$/)

      first_part.singularize
    end
  end

  class ApiError < StandardError
    attr_reader :details

    def initialize(message, details = nil)
      super(message)
      @details = details
    end
  end
end
