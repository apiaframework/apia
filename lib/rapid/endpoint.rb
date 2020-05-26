# frozen_string_literal: true

require 'rapid/helpers'
require 'rapid/defineable'
require 'rapid/definitions/endpoint'
require 'rapid/request_environment'

module Rapid
  class Endpoint

    extend Defineable

    class << self

      # Return the definition object for the endpoint
      #
      # @return [Rapid::Definitions::Endpoint]
      def definition
        @definition ||= Definitions::Endpoint.new(Helpers.class_name_to_id(name))
      end

      # Collate all objects that this endpoint references and add them to the
      # given object set
      #
      # @param set [Rapid::ObjectSet]
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
      # @param request [Rapid::Request]
      # @return [Rapid::Response]
      def execute(request)
        environment = RequestEnvironment.new(request)
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

          # We're going to call this here because we want to cache the actual values of
          # the output within the catch_errors block.
          response.hash
        end

        response
      end

      # Catch any runtime errors and update the given response with the appropriate
      # values.
      #
      # @param response [Rapid::Response]
      # @return [void]
      def catch_errors(response)
        yield
      rescue Rapid::RuntimeError => e
        catch_errors(response) do
          response.body = { error: e.hash }
          response.status = e.http_status
          response.headers['x-api-schema'] = 'json-error'
        end
      end

    end

  end
end