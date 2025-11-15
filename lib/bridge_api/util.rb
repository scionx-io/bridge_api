# frozen_string_literal: true

module BridgeApi
  module Util
    OBJECT_CLASS_NAMES = {
      'wallet' => 'BridgeApi::Resources::Wallet',
      'customer' => 'BridgeApi::Resources::Customer',
      'transaction_history' => 'BridgeApi::Resources::TransactionHistory',
      'reward_rate' => 'BridgeApi::Resources::RewardRate',
      'kyc_link' => 'BridgeApi::Resources::KycLink',
      'webhook' => 'BridgeApi::Resources::Webhook',
      'webhook_event' => 'BridgeApi::Resources::WebhookEvent',
      'webhook_event_delivery_log' => 'BridgeApi::Resources::WebhookEventDeliveryLog',
      'virtual_account' => 'BridgeApi::Resources::VirtualAccount',
    }.freeze

    RESOURCE_PATTERNS = {
      'wallet' => { all: %i[id chain address] },
      'customer' => { all: %i[id], any: %i[email name customer_type] },
      'virtual_account' => { all: %i[id account_number] },
      'transaction_history' => { all: %i[id], any: %i[amount transaction_date] },
      'kyc_link' => { all: %i[id redirect_url] },
    }.freeze

    class << self
      # Convert API response data to appropriate resource objects
      def convert_to_bridged_object(data, opts = {})
        case data
        when Array
          data.map { |item| convert_to_bridged_object(item, opts) }
        when Hash
          if data.key?('data') || data.key?(:data)
            convert_list_object(data, opts)
          elsif (object_name = detect_resource_type_from_object_field(data))
            construct_resource(object_name, symbolize_keys(data), opts)
          elsif (resource_hint = opts[:resource_hint]) && OBJECT_CLASS_NAMES.key?(resource_hint.to_s)
            construct_resource(resource_hint.to_s, symbolize_keys(data), opts)
          elsif (detected_type = detect_resource_type(data))
            construct_resource(detected_type, symbolize_keys(data), opts)
          else
            symbolize_keys(data).transform_values { |value| convert_to_bridged_object(value, opts) }
          end
        else
          data
        end
      end

      private

      def detect_resource_type_from_object_field(data)
        object_name = data['object'] || data[:object]
        object_name && OBJECT_CLASS_NAMES.key?(object_name.to_s) ? object_name.to_s : nil
      end

      def convert_list_object(data, opts)
        list_data = symbolize_keys(data)
        if list_data[:data].is_a?(Array)
          list_data[:data] = list_data[:data].map do |item|
            convert_to_bridged_object(item, opts)
          end
        end
        BridgeApi::ListObject.new(list_data)
      end

      def detect_resource_type(data)
        return nil unless data.is_a?(Hash)

        RESOURCE_PATTERNS.each do |resource_type, pattern|
          all_keys_present = Array(pattern[:all]).all? { |key| data.key?(key) || data.key?(key.to_s) }
          any_key_present = !pattern[:any] || Array(pattern[:any]).any? { |key| data.key?(key) || data.key?(key.to_s) }

          return resource_type if all_keys_present && any_key_present && OBJECT_CLASS_NAMES.key?(resource_type)
        end

        nil
      end

      def construct_resource(object_name, data, opts)
        klass = Object.const_get(OBJECT_CLASS_NAMES[object_name])
        if klass.respond_to?(:construct_from)
          klass.construct_from(data, opts)
        else
          klass.new(data)
        end
      end

      def symbolize_keys(obj)
        case obj
        when Hash
          obj.transform_keys(&:to_sym).transform_values { |value| symbolize_keys(value) }
        when Array
          obj.map { |item| symbolize_keys(item) }
        else
          obj
        end
      end
    end
  end
end
