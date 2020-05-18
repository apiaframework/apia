# frozen_string_literal: true

require 'rapid/helpers'
require 'rapid/definitions/object'
require 'rapid/defineable'

module Rapid
  class Object

    extend Defineable

    class << self

      # Return the definition for this type
      #
      # @return [Rapid::Definitions::Object]
      def definition
        @definition ||= Definitions::Object.new(Helpers.class_name_to_id(name))
      end

      # Collate all objects that this type references and add them to the
      # given object set
      #
      # @param set [Rapid::ObjectSet]
      # @return [void]
      def collate_objects(set)
        definition.fields.each_value do |field|
          set.add_object(field.type.klass) if field.type.usable_for_field?
        end
      end

    end

    # Initialize an instance of this type with the value provided
    #
    # @param value [Object, Hash]
    # @return [Rapid::Object]
    def initialize(value)
      @value = value
    end

    # Return the raw value object for this type
    #
    # @return [Object, Hash]
    attr_reader :value

    # Generate a hash based on the fields defined in this type
    #
    # @param request [Rapid::Request] the associated request
    # @return [Hash]
    def hash(request: nil, path: [])
      self.class.definition.fields.generate_hash(@value, request: request, path: path)
    end

    # Should this type be included in any output?
    #
    # @param request [Rapid::Request]
    # @return [Boolean]
    def include?(request)
      return true if self.class.definition.conditions.empty?

      self.class.definition.conditions.all? do |cond|
        cond.call(@value, request) == true
      end
    end

  end
end
