# frozen_string_literal: true

require 'rack/request'
require 'rapid/request_headers'
require 'rapid/errors/invalid_json_error'
require 'rapid/field_spec'

module Rapid
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
      return unless content_type =~ /\Aapplication\/json/
      return unless body?

      @json_body ||= begin
                       JSON.parse(body.read)
                     rescue JSON::ParserError => e
                       raise InvalidJSONError, e.message
                     end
    end

    def body?
      has_header?('rack.input')
    end

    def field_spec
      return @field_spec if instance_variable_defined?('@field_spec')

      @field_spec = begin
        if json_body && string = json_body['fields']
          FieldSpec.parse(string)
        elsif body? && string = params['fields']
          FieldSpec.parse(string)
        elsif string = headers['x-field-spec']
          FieldSpec.parse(string)
        elsif @endpoint
          @endpoint.definition.fields.spec
        end
      end
    end

  end
end
