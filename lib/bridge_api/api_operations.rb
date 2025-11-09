# frozen_string_literal: true

module BridgeApi
  module APIOperations
    # Module for resources that support listing
    module List
      def self.included(base)
        base.extend(ClassMethods)
      end

      module ClassMethods
        def list(client, params = {})
          response = client.request(:get, resource_path, params)
          return response unless response.success?

          # Create a list response - for now return as is but can be enhanced later
          response
        end
      end
    end

    # Module for resources that support creation
    module Create
      def self.included(base)
        base.extend(ClassMethods)
      end

      module ClassMethods
        def create(client, params = {})
          response = client.request(:post, resource_path, params)
          return response unless response.success?

          construct_from(response.data)
        end
      end
    end

    # Module for resources that support retrieving
    module Retrieve
      def self.included(base)
        base.extend(ClassMethods)
      end

      module ClassMethods
        def retrieve(client, id, params = {})
          response = client.request(:get, "#{resource_path}/#{id}", params)
          return response unless response.success?

          construct_from(response.data)
        end
      end
    end

    # Module for resources that support updating
    module Update
      def update(client, params = {})
        id = @values[:id]
        raise ArgumentError, 'Cannot update resource without ID' unless id

        response = client.request(:patch, "#{self.class.resource_path}/#{id}", params)
        return response unless response.success?

        update_attributes(response.data)
        clear_changes
        self
      end
    end

    # Module for resources that support deletion
    module Delete
      def delete(client)
        id = @values[:id]
        raise ArgumentError, 'Cannot delete resource without ID' unless id

        response = client.request(:delete, "#{self.class.resource_path}/#{id}", {})
        return response unless response.success?

        @values[:deleted] = true
        self
      end
    end
  end
end
