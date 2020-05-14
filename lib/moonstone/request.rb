# frozen_string_literal: true

require 'rack/request'
require 'moonstone/request_headers'
require 'moonstone/errors/invalid_json_error'

module Moonstone
  class Request < Rack::Request

    attr_accessor :api
    attr_accessor :controller
    attr_accessor :endpoint
    attr_accessor :identity
    attr_accessor :arguments
    attr_accessor :authenticator
    attr_accessor :namespace

    def self.empty(options: {})
      new(options)
    end

    def headers
      @headers ||= RequestHeaders.create_from_request(self)
    end

    def json_body
      return unless content_type =~ /\Aapplication\/json/

      @json_body ||= begin
        JSON.parse(body.read)
                     rescue JSON::ParserError => e
                       raise InvalidJSONError, e.message
      end
    end

  end
end
