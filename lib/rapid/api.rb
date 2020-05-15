# frozen_string_literal: true

require 'rapid/helpers'
require 'rapid/defineable'
require 'rapid/definitions/api'
require 'rapid/object_set'
require 'rapid/manifest_errors'

module Rapid
  class API

    extend Defineable

    def self.definition
      @definition ||= Definitions::API.new(Helpers.class_name_to_id(name))
    end

    def self.objects
      set = ObjectSet.new([self])
      set.add_object(definition.authenticator) if definition.authenticator
      definition.controllers.each_value { |con| set.add_object(con) }
      set
    end

    # Validate all objects in the API and return them
    #
    # @return [Rapid::ManifestErrors]
    def self.validate_all
      errors = ManifestErrors.new
      objects.each do |object|
        next unless object.respond_to?(:definition)

        object.definition.validate(errors)
      end
      errors
    end

  end
end
