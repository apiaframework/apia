# frozen_string_literal: true

require 'rapid/defineable'
require 'rapid/definitions/api'
require 'rapid/helpers'
require 'rapid/manifest_errors'
require 'rapid/object_set'

module Rapid
  class API

    extend Defineable

    class << self

      # Return the definition for this API
      #
      # @return [Rapid::Definitions::API]
      def definition
        @definition ||= Definitions::API.new(Helpers.class_name_to_id(name))
      end

      # Return all objects which are referenced by the API. This list is used for the purposes
      # of validating all objects and generating schemas.
      #
      # @param include_rapid_controller [Boolean] whether the schema/internal API should be included
      # @return [Rapid::ObjectSet]
      def objects
        set = ObjectSet.new([self])
        if definition.authenticator
          set.add_object(definition.authenticator)
        end

        definition.route_set.controllers.each do |con|
          set.add_object(con)
        end

        set
      end

      # Validate all objects in the API and return details of any issues encountered
      #
      # @return [Rapid::ManifestErrors]
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
        require 'rapid/schema/controller'
        Schema::Controller.definition.endpoints[:schema].definition.fields.generate_hash({
          schema_version: 1,
          host: host,
          namespace: namespace,
          api: definition.id,
          objects: objects.map(&:definition).select(&:schema?)
        })
      end

    end

  end
end
