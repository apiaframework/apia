# frozen_string_literal: true

require 'json'
require 'apia/rack'

module Apia
  class Response

    TYPES = [
      JSON = 'application/json',
      PLAIN = 'text/plain'
    ].freeze

    attr_accessor :status
    attr_reader :fields
    attr_reader :headers
    attr_writer :body

    def initialize(request, endpoint)
      @request = request
      @endpoint = endpoint

      @status = @endpoint.definition.http_status_code
      @type = @endpoint.definition.response_type
      @fields = {}
      @headers = {}
    end

    def plain_text_body(body)
      warn '[DEPRECATION] `plain_text_body` is deprecated. Please set use `response_type` in the endpoint definition, and set the response `body` directly instead.'

      @type = PLAIN
      @body = body
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
      @hash ||= @endpoint.definition.fields.generate_hash(@fields, request: @request)
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
      # Errors will always be sent as a hash intended for JSON encoding,
      # even if the endpoint specifies a plain text response, so only
      # send a pain response if the type is plaintext _and_ the body is
      # a string
      if @type == PLAIN && body.is_a?(String)
        Rack.plain_triplet(body, headers: headers, status: status)
      else
        Rack.json_triplet(body, headers: headers, status: status)
      end
    end

  end
end
