# frozen_string_literal: true

module BridgeApi
  module Util
    # Map of object names to their corresponding classes for automatic conversion
    def self.object_classes
      {
        'wallet' => BridgeApi::Resources::Wallet,
        'customer' => BridgeApi::Resources::Customer,
        'transaction_history' => BridgeApi::Resources::TransactionHistory,
        'reward_rate' => BridgeApi::Resources::RewardRate,
        'kyc_link' => BridgeApi::Resources::KycLink,
        'webhook' => BridgeApi::Resources::Webhook,
        'webhook_event' => BridgeApi::Resources::WebhookEvent,
        'webhook_event_delivery_log' => BridgeApi::Resources::WebhookEventDeliveryLog,
        'virtual_account' => BridgeApi::Resources::VirtualAccount,
      }
    end

    # Convert API response data to appropriate resource objects
    def self.convert_to_bridged_object(data, opts = {})
      resource_hint = opts[:resource_hint]

      case data
      when Array
        data.map { |item| convert_to_bridged_object(item, opts) }
      when Hash
        # Check if this is a list object (has 'data' key, optional 'count')
        if data.key?('data') || data.key?(:data)
          # This looks like a list response, convert to ListObject
          list_data = symbolize_keys(data)
          # Convert the data array items recursively if data exists
          if list_data[:data].is_a?(Array)
            list_data[:data] = list_data[:data].map do |item|
              convert_to_bridged_object(item, opts)
            end
          end
          BridgeApi::ListObject.new(list_data)
        # Check if this is a resource object with an 'object' field
        elsif (object_name = data['object'] || data[:object]) && object_classes.key?(object_name.to_s)
          construct_resource(object_name.to_s, symbolize_keys(data), opts)
        elsif resource_hint && object_classes.key?(resource_hint.to_s)
          # Use hint if no object field present
          construct_resource(resource_hint.to_s, symbolize_keys(data), opts)
        elsif likely_resource_type(data)
          # Auto-detect resource type based on common fields
          object_name = likely_resource_type(data)
          construct_resource(object_name, symbolize_keys(data), opts)
        else
          # For non-resource objects, return as is or convert nested objects
          convert_nested_objects(symbolize_keys(data))
        end
      else
        data
      end
    end

    # Convert hash keys to symbols recursively
    def self.symbolize_keys(obj)
      case obj
      when Hash
        obj.each_with_object({}) do |(key, value), new_hash|
          new_hash[key.to_sym] = symbolize_keys(value)
        end
      when Array
        obj.map { |item| symbolize_keys(item) }
      else
        obj
      end
    end

    def self.construct_resource(object_name, data, opts)
      klass = object_classes[object_name]
      if klass.respond_to?(:construct_from)
        klass.construct_from(data, opts)
      else
        klass.new(data)
      end
    end

    # Attempt to detect resource type based on common identifying fields
    def self.likely_resource_type(data)
      return false unless data.is_a?(Hash)

      # Search for the first matching resource type
      resource_checks = {
        'wallet' => ->(d) { all_keys?(d, %i[id chain address]) },
        'customer' => ->(d) { all_keys?(d, %i[id]) && any_key?(d, %i[email name customer_type]) },
        'virtual_account' => ->(d) { all_keys?(d, %i[id account_number]) },
        'transaction_history' => ->(d) { all_keys?(d, %i[id]) && any_key?(d, %i[amount transaction_date]) },
        'kyc_link' => ->(d) { all_keys?(d, %i[id redirect_url]) },
      }

      resource_checks.each do |resource_type, check_proc|
        return resource_type if check_proc.call(data) && object_classes.key?(resource_type)
      end

      false
    end

    # Helper method to check if data has all the specified keys
    def self.all_keys?(data, keys)
      keys.all? { |key| data.key?(key) }
    end

    # Helper method to check if data has at least one of the specified keys
    def self.any_key?(data, keys)
      keys.any? { |key| data.key?(key) }
    end

    # Recursively convert nested objects that look like API resources
    def self.convert_nested_objects(data)
      case data
      when Hash
        # Check if this is a likely resource object (has id, object type, etc.)
        if data[:id] && data[:object]
          convert_resource_object(data)
        else
          # Recursively check nested values
          data.transform_values do |value|
            convert_nested_objects(value)
          end
        end
      when Array
        data.map { |item| convert_nested_objects(item) }
      else
        data
      end
    end

    private_class_method def self.convert_resource_object(data)
      object_name = data[:object]
      if object_classes.key?(object_name.to_s)
        klass = object_classes[object_name.to_s]
        if klass.respond_to?(:construct_from)
          klass.construct_from(data)
        else
          klass.new(data)
        end
      else
        # Recursively check nested values
        data.transform_values do |value|
          convert_nested_objects(value)
        end
      end
    end
  end
end
