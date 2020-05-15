# frozen_string_literal: true

require 'rapid/defineable'
require 'rapid/definitions/api'
require 'rapid/helpers'
require 'rapid/internal_api/controller'
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
      def objects(include_rapid_controller: false)
        set = ObjectSet.new([self])
        set.add_object(definition.authenticator) if definition.authenticator
        definition.controllers.each_value do |con|
          if con == InternalAPI::Controller && include_rapid_controller == false
            next
          end

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

    end

  end
end
