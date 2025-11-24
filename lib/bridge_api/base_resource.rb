# frozen_string_literal: true
require 'json'

module BridgeApi
  # Base class for all Bridge API resource objects
  # Provides common functionality for attribute access and object conversion
  class BaseResource
    include Enumerable

    def initialize(attributes = {})
      @values = {}
      @unsaved_values = Set.new
      @transient_values = Set.new

      update_attributes(attributes) if attributes
    end

    # Compare two resources for equality
    def ==(other)
      other.is_a?(BaseResource) &&
        @values == other.instance_variable_get(:@values)
    end

    def eql?(other)
      self == other
    end

    def hash
      @values.hash
    end

    # Mass assign attributes
    def update_attributes(attributes)
      attributes&.each do |key, value|
        set_attribute(key.to_sym, value)
      end
    end

    # Get an attribute value
    def [](key)
      @values[key.to_sym]
    end

    # Set an attribute value
    def []=(key, value)
      set_attribute(key.to_sym, value)
    end

    # Get all attribute keys
    def keys
      @values.keys
    end

    # Get all attribute values
    def values
      @values.values
    end

    # Serialize to JSON
    def to_json(*_opts)
      JSON.generate(@values)
    end

    # Convert to JSON-compatible hash
    def as_json(*_opts)
      @values.as_json
    end

    # Convert to hash representation
    def to_hash
      @values.transform_values do |value|
        case value
        when Array
          value.map { |v| v.respond_to?(:to_hash) ? v.to_hash : v }
        when BaseResource
          value.to_hash
        else
          value
        end
      end
    end

    # Alias for backward compatibility
    alias to_h to_hash

    # Iterate over attributes
    def each(&)
      @values.each(&)
    end

    # Check if attribute exists
    def key?(key)
      @values.key?(key.to_sym)
    end

    # Check if resource has unsaved changes
    def changed?
      !@unsaved_values.empty?
    end

    # Get list of changed attributes
    def changes
      @unsaved_values.to_a
    end

    # Mark all values as saved
    def clear_changes
      @unsaved_values.clear
    end

    # Construct a resource from a hash of attributes
    def self.construct_from(attributes, _opts = {})
      new(attributes)
    end

    private

    # Set an attribute
    def set_attribute(key, value)
      @values[key] = convert_value(value)
      @unsaved_values.add(key)
    end

    # Dynamic method handling for all attributes in @values
    # Only allows attribute access without arguments, raises error if arguments are provided
    def method_missing(method_name, *args)
      if args.empty? && @values.key?(method_name)
        @values[method_name]
      else
        super
      end
    end

    def respond_to_missing?(method_name, include_private = false)
      @values.key?(method_name) || super
    end

    # Convert values to appropriate types when possible
    def convert_value(value)
      case value
      when Array
        value.map { |v| convert_value(v) }
      when Hash
        value.each_with_object({}) { |(k, v), hash| hash[k.to_sym] = convert_value(v) }
      else
        value
      end
    end
  end
end
