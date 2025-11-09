# frozen_string_literal: true

module BridgeApi
  # Represents a collection of API resources with pagination
  class ListObject < BaseResource
    include Enumerable

    def initialize(attributes = {})
      super
    end

    def data
      @values[:data] || []
    end

    def count
      @values[:count] || data.length
    end

    def more?
      @values[:has_more] || false
    end

    def url
      @values[:url]
    end

    def [](index)
      data[index]
    end

    def each(&)
      data.each(&)
    end

    def empty?
      data.empty?
    end

    def size
      data.length
    end

    def length
      size
    end

    def first
      data.first
    end

    def last
      data.last
    end
  end
end
