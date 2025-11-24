# frozen_string_literal: true
module BridgeApi
  module Services
    class BaseService
      def initialize(client)
        @client = client
      end

      protected

      def request(method, endpoint, params = {}, idempotency_key: nil)
        if idempotency_key
          @client.send(:request_with_idempotency, method, endpoint, params, idempotency_key)
        else
          @client.send(:request, method, endpoint, params)
        end
      end
    end
  end
end
