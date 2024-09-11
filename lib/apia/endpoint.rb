# frozen_string_literal: true

require 'apia/helpers'
require 'apia/defineable'
require 'apia/definitions/endpoint'
require 'apia/request_environment'
require 'apia/errors/scope_not_granted_error'
require 'apia/callable_with_environment'

module Apia
  class Endpoint

    extend Defineable
    include CallableWithEnvironment

    class << self

      # Return the definition object for the endpoint
      #
      # @return [Apia::Definitions::Endpoint]
      def definition
        @definition ||= Definitions::Endpoint.new(Helpers.class_name_to_id(name))
      end

      # Collate all objects that this endpoint references and add them to the
      # given object set
      #
      # @param set [Apia::ObjectSet]
      # @return [void]
      def collate_objects(set)
        set.add_object(definition.argument_set)

        definition.potential_errors.each do |error|
          set.add_object(error)
        end

        definition.fields.each_value do |field|
          set.add_object(field.type.klass) if field.type.usable_for_field?
        end
      end

      # Run this request by providing a request to execute it with.
      #
      # @param request [Apia::Request]
      # @return [Apia::Response]
      def execute(request)
        response = Response.new(request, self)
        environment = RequestEnvironment.new(request, response)

        catch_errors(response, environment) do
          # Determine an authenticator for this endpoint
          request.authenticator = definition.authenticator || request.controller&.definition&.authenticator || request.api&.definition&.authenticator

          # Execute the authentication before the request happens
          request.authenticator&.execute(environment)

          # Add the CORS headers to the response before the endpoint is called. The endpoint
          # cannot influence the CORS headers.
          response.headers.merge!(environment.cors.to_headers)

          # OPTIONS requests always return 200 OK and no body.
          if request.options?
            response.status = 200
            response.body = ''
            return response
          end

          # Determine if we're permitted to run the action based on the endpoint's scopes
          if request.authenticator && !request.authenticator.authorized_scope?(environment, definition.scopes)
            environment.raise_error Apia::ScopeNotGrantedError, scopes: definition.scopes
          end

          # Process arguments into the request. This happens after the authentication
          # stage because a) authenticators shouldn't be using endpoint specific args
          # and b) the argument conditions may need to know the identity.
          request.arguments = definition.argument_set.create_from_request(request)

          # Call the action for the endpoint
          endpoint_instance = new(environment)
          endpoint_instance.call_with_error_handling

          # We're going to call this here because we want to cache the actual values of
          # the output within the catch_errors block.
          response.hash
        end

        response
      end

      # Catch any runtime errors and update the given response with the appropriate
      # values.
      #
      # @param response [Apia::Response]
      # @return [void]
      def catch_errors(response, environment)
        yield
      rescue Apia::RuntimeError => e
        # If the error was triggered by the authenticator, the cors headers wont yet have been merged
        # so ensure cors headers are merged here
        response.headers.merge!(environment.cors.to_headers)

        catch_errors(response, environment) do
          response.body = { error: e.hash }
          response.status = e.http_status
          response.headers['x-api-schema'] = 'json-error'
        end
      end

      # Should a given field be included
      #
      def include_field?(*args)
        definition.fields.spec.include_field?(*args)
      end

      # Allow an endpoint to be executed with a mocked request.
      #
      def test
        request = Apia::MockRequest.empty
        request.endpoint = self
        yield request if block_given?
        execute(request)
      end

    end

  end
end
