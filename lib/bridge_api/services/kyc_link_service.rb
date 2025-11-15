# frozen_string_literal: true
module BridgeApi
  module Services
    class KycLinkService < BaseService
      def create(params = {}, idempotency_key: nil)
        request(:post, 'kyc_links', params, idempotency_key: idempotency_key)
      end

      def retrieve(id, params = {})
        request(:get, "kyc_links/#{id}", params)
      end

      def list(params = {})
        request(:get, 'kyc_links', params)
      end
    end
  end
end