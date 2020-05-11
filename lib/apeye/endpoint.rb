# frozen_string_literal: true

require 'apeye/defineable'
require 'apeye/definitions/endpoint'

module APeye
  class Endpoint
    extend Defineable

    def self.definition
      @definition ||= Definitions::Endpoint.new(name&.split('::')&.last)
    end

    def self.collate_objects(set)
      definition.potential_errors.each do |error|
        set.add_object(error)
      end

      definition.arguments.values.each do |argument|
        set.add_object(argument.type)
      end

      definition.fields.values.each do |field|
        set.add_object(field.type)
      end
    end

    # Run this request by providing a request to execute it with.
    #
    # @param request [APeye::Request]
    # @return [APeye::Response]
    def self.execute(request)
      response = Response.new(request, self)

      begin
        # Determine an authenticator and execute it before the request happens
        authenticator = definition.authenticator || request.controller&.definition&.authenticator || request.api&.definition&.authenticator
        authenticator&.execute(request, response)

        # Process arguments into the request. This happens after the authentication
        # stage because a) authenticators shouldn't be using endpoint specific args
        # and b) the argument conditions may need to know the identity.
        request.arguments = definition.argument_set.create_from_request(request)

        definition.action&.call(request, response)
      rescue APeye::RuntimeError => e
        response.body = { error: e.hash }
        response.status = e.http_status
      end

      response
    end
  end
end
