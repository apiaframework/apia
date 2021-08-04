# frozen_string_literal: true

require 'apia/defineable'
require 'apia/definitions/api'
require 'apia/helpers'
require 'apia/manifest_errors'
require 'apia/object_set'
require 'apia/errors/standard_error'
require 'apia/mock_request'

module Apia
  class API

    extend Defineable

    class << self

      # Return the definition for this API
      #
      # @return [Apia::Definitions::API]
      def definition
        @definition ||= Definitions::API.new(Helpers.class_name_to_id(name))
      end

      # Return all objects which are referenced by the API. This list is used for the purposes
      # of validating all objects and generating schemas.
      #
      # @param include_apia_controller [Boolean] whether the schema/internal API should be included
      # @return [Apia::ObjectSet]
      def objects
        set = ObjectSet.new([self])
        if definition.authenticator
          set.add_object(definition.authenticator)
        end

        definition.route_set.controllers.each do |con|
          set.add_object(con)
        end

        definition.route_set.endpoints.each do |endpoint|
          set.add_object(endpoint)
        end

        set
      end

      # Validate all objects in the API and return details of any issues encountered
      #
      # @return [Apia::ManifestErrors]
      def validate_all
        errors = ManifestErrors.new
        objects.each do |object|
          next unless object.respond_to?(:definition)

          object.definition.validate(errors)
        end
        errors
      end

      # Return the schema hash for this API
      #
      # @param host [String]
      # @param namespace [String]
      # @return [Hash]
      def schema(host:, namespace:)
        require 'apia/schema/controller'
        Schema::Controller.definition.endpoints[:schema].definition.fields.generate_hash({
          schema_version: 1,
          host: host,
          namespace: namespace,
          api: definition.id,
          objects: objects.map(&:definition).select(&:schema?)
        })
      end

      # Execute a request for a given controller & endpoint
      #
      # @param controller [Apia::Controller]
      # @param endpoint_name [Symbol]
      # @return [Apia::Response]
      def test_endpoint(endpoint, controller: nil)
        if controller && endpoint.is_a?(Symbol) || endpoint.is_a?(String)
          endpoint_name = endpoint
          endpoint = controller.definition.endpoints[endpoint.to_sym]
          if endpoint.nil?
            raise Apia::StandardError, "Invalid endpoint name '#{endpoint_name}' for '#{controller.name}'"
          end
        end

        endpoint.test do |r|
          r.api = self
          r.controller = controller
          yield r if block_given?
        end
      end

    end

  end
end
