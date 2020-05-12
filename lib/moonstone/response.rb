# frozen_string_literal: true

require 'json'
require 'moonstone/rack'

module Moonstone
  class Response
    attr_accessor :status
    attr_accessor :body
    attr_reader :fields
    attr_reader :headers

    def initialize(request, endpoint)
      @request = request
      @endpoint = endpoint

      @status = 200
      @fields = {}
      @headers = {}
    end

    # Add a field value for this endpoint
    #
    # @param name [Symbol]
    # @param value [Hash, Object, nil]
    # @return [void]
    def add_field(name, value)
      @fields[name.to_sym] = value
    end

    # Add a header to the response
    #
    # @param name [String]
    # @param value [String]
    # @return [void]
    def add_header(name, value)
      @headers[name.to_s] = value&.to_s
    end

    # Return the full hash of data that should be returned for this
    # request.
    #
    # @return [Hash]
    def hash
      @hash ||= @endpoint.definition.generate_hash_for_fields(@fields, request: @request)
    end

    # Return the body that should be returned for this response
    #
    # @return [Hash]
    def body
      @body || hash
    end

    # Return the rack triplet for this response
    #
    # @return [Array]
    def rack_triplet
      Rack.json_triplet(body, headers: @headers, status: @status)
    end
  end
end
