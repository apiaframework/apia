# frozen_string_literal: true

require 'moonstone/defineable'
require 'moonstone/definitions/endpoint'
require 'moonstone/environment'

module Moonstone
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
    # @param request [Moonstone::Request]
    # @return [Moonstone::Response]
    def self.execute(request)
      environment = Environment.new(request)
      response = Response.new(request, self)

      catch_errors(response) do
        # Determine an authenticator and execute it before the request happens
        request.authenticator = definition.authenticator || request.controller&.definition&.authenticator || request.api&.definition&.authenticator
        request.authenticator&.execute(environment, response)

        # Process arguments into the request. This happens after the authentication
        # stage because a) authenticators shouldn't be using endpoint specific args
        # and b) the argument conditions may need to know the identity.
        request.arguments = definition.argument_set.create_from_request(request)

        environment.call(response, &definition.action)
      end

      response
    end

    # Catch any runtime errors and update the given response with the appropriate
    # values.
    #
    # @param response [Moonstone::Response]
    # @return [void]
    def self.catch_errors(response)
      yield
    rescue Moonstone::RuntimeError => e
      catch_errors(response) do
        response.body = { error: e.hash }
        response.status = e.http_status
      end
    end
  end
end
