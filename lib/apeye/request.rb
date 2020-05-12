# frozen_string_literal: true

require 'rack/request'
require 'apeye/request_headers'
require 'apeye/errors/invalid_json_error'

module APeye
  class Request < Rack::Request
    attr_accessor :api
    attr_accessor :controller
    attr_accessor :endpoint
    attr_accessor :identity
    attr_accessor :arguments
    attr_accessor :authenticator

    def self.empty(options: {})
      new(options)
    end

    def headers
      @headers ||= RequestHeaders.create_from_request(self)
    end

    def json_body
      return unless content_type =~ %r{\Aapplication/json}

      @json_body ||= begin
        JSON.parse(body.read)
                     rescue JSON::ParserError => e
                       raise InvalidJSONError, e.message
      end
    end
  end
end
