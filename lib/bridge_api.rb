# frozen_string_literal: true
require 'httparty'
require 'json'
require 'securerandom'
require_relative 'bridge_api/version'

module BridgeApi
  class << self
    attr_accessor :api_key, :sandbox_mode
    attr_writer :base_url

    def config
      yield self
    end

    def base_url
      @base_url || default_base_url
    end

    private

    def default_base_url
      if sandbox_mode
        'https://api.sandbox.bridge.xyz/v0/'
      else
        'https://api.bridge.xyz/v0/'
      end
    end
  end
end

require_relative 'bridge_api/client'
