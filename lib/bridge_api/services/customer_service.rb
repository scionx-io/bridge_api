# frozen_string_literal: true
module BridgeApi
  module Services
    class CustomerService < BaseService
      def create(params = {}, idempotency_key: nil)
        request(:post, 'customers', params, idempotency_key: idempotency_key)
      end

      def retrieve(id, params = {})
        response = request(:get, "customers/#{id}", params)
        return response unless response.success?

        # Return a Customer object directly if the request was successful
        BridgeApi::Resources::Customer.construct_from(response.data)
      end

      def list(params = {})
        request(:get, 'customers', params)
      end

      def update(id, params = {}, idempotency_key: nil)
        request(:patch, "customers/#{id}", params, idempotency_key: idempotency_key)
      end
    end
  end
end
