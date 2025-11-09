# frozen_string_literal: true

module BridgeApi
  # Base class for API resources that can be retrieved, updated, etc.
  class APIResource < BaseResource
    # Default object name - to be overridden by subclasses
    OBJECT_NAME = nil

    def self.object_name
      self::OBJECT_NAME
    end

    def self.class_name
      name.split('::')[-1]
    end

    # Default resource path - to be overridden by subclasses
    def self.resource_path
      "/#{object_name.downcase}s" if object_name
    end

    def resource_path
      self.class.resource_path
    end

    # Class methods for API operations
    def self.retrieve(client, id, params = {})
      response = client.request(:get, "#{resource_path}/#{id}", params)
      return response unless response.success?

      construct_from(response.data)
    end

    def self.list(client, params = {})
      response = client.request(:get, resource_path, params)
      return response unless response.success?

      BridgeApi::Util.convert_to_bridged_object(
        response,
        resource_hint: self::OBJECT_NAME,
      )
    end

    def self.create(client, params = {})
      response = client.request(:post, resource_path, params)
      return response unless response.success?

      construct_from(response.data)
    end

    # Instance methods for API operations
    def update(client, params = {})
      id = @values[:id]
      raise ArgumentError, 'Cannot update resource without ID' unless id

      response = client.request(:patch, "#{resource_path}/#{id}", params)
      return response unless response.success?

      update_attributes(response.data)
      clear_changes
      self
    end

    def delete(client)
      id = @values[:id]
      raise ArgumentError, 'Cannot delete resource without ID' unless id

      response = client.request(:delete, "#{resource_path}/#{id}", {})
      return response unless response.success?

      @values[:deleted] = true
      self
    end

    # Check if resource is deleted (if the API supports it)
    def deleted?
      @values[:deleted] || false
    end
  end
end
