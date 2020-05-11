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

    def self.empty
      new({})
    end

    def headers
      @headers ||= RequestHeaders.create_from_request(self)
    end

    def json_body
      return unless content_type =~ %r{\Aapplication/json}

      @json_body ||= begin
        body.rewind
        JSON.parse(body.read)
                     rescue JSON::ParserError => e
                       raise InvalidJSONError, e.message
      end
    end
  end
end
