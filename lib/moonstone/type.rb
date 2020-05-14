# frozen_string_literal: true

require 'moonstone/helpers'
require 'moonstone/definitions/type'
require 'moonstone/defineable'

module Moonstone
  class Type

    extend Defineable

    # Return the definition for this type
    #
    # @return [Moonstone::Definitions::Type]
    def self.definition
      @definition ||= Definitions::Type.new(Helpers.class_name_to_id(name))
    end

    # Collate all objects that this type references and add them to the
    # given object set
    #
    # @param set [Moonstone::ObjectSet]
    # @return [void]
    def self.collate_objects(set)
      definition.fields.each_value do |field|
        set.add_object(field.type)
      end
    end

    def self.name_for(object)
      if object.respond_to?(:ancestors)
        if object.ancestors.include?(Moonstone::Scalar)
          return object.definition.id
        elsif object.ancestors.include?(Moonstone::Type)
          return object.definition.id
        end
      end

      object.name
    end

    # Initialize an instance of this type with the value provided
    #
    # @param value [Object, Hash]
    # @return [Moonstone::Type]
    def initialize(value)
      @value = value
    end

    # Return the raw value object for this type
    #
    # @return [Object, Hash]
    attr_reader :value

    # Generate a hash based on the fields defined in this type
    #
    # @param request [Moonstone::Request] the associated request
    # @return [Hash]
    def hash(request: nil)
      self.class.definition.fields.generate_hash(@value, request: request)
    end

    # Should this type be included in any output?
    #
    # @param request [Moonstone::Request]
    # @return [Boolean]
    def include?(request)
      return true if self.class.definition.conditions.empty?

      self.class.definition.conditions.all? do |cond|
        cond.call(@value, request) == true
      end
    end

  end
end
