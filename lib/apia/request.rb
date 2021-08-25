# frozen_string_literal: true

require 'rack/request'
require 'apia/request_headers'
require 'apia/errors/invalid_json_error'

module Apia
  class Request < Rack::Request

    attr_accessor :api
    attr_accessor :controller
    attr_accessor :endpoint
    attr_accessor :identity
    attr_writer :arguments
    attr_accessor :authenticator
    attr_accessor :namespace
    attr_accessor :route
    attr_accessor :api_path

    def self.empty(options: {})
      new(options)
    end

    def arguments
      @arguments ||= {}
    end

    def headers
      @headers ||= RequestHeaders.create_from_request(self)
    end

    def json_body
      return @json_body if instance_variable_defined?('@json_body')

      @json_body = get_json_body_from_body || get_json_body_from_params
    end

    def body?
      has_header?('rack.input')
    end

    def params
      return {} unless body?

      super
    end

    private

    def parse_json_from_string(body)
      return {} if body.empty?

      JSON.parse(body)
    rescue JSON::ParserError => e
      raise InvalidJSONError, e.message
    end

    def get_json_body_from_body
      return unless content_type =~ /\Aapplication\/json/
      return unless body?

      parse_json_from_string(body.read)
    end

    def get_json_body_from_params
      return unless body?
      return unless params['_arguments'].is_a?(String)

      parse_json_from_string(params['_arguments'])
    end

  end
end
