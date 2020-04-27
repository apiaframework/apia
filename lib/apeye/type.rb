# frozen_string_literal: true

require 'apeye/definitions/type'
require 'apeye/dsls/type'
require 'apeye/defineable'

module APeye
  class Type
    extend Defineable

    # Return the definition for this type
    #
    # @return [APeye::Definitions::Type]
    def self.definition
      @definition ||= Definitions::Type.new(name&.split('::')&.last)
    end

    # Collate all objects that this type references and add them to the
    # given object set
    #
    # @param set [APeye::ObjectSet]
    # @return [void]
    def self.collate_objects(set)
      definition.fields.values.each do |field|
        set.add_object(field.type)
      end
    end

    # Initialize an instance of this type with the value provided
    #
    # @param value [Object, Hash]
    # @return [APeye::Type]
    def initialize(value)
      @value = value
    end

    # Return the raw value object for this type
    #
    # @return [Object, Hash]
    attr_reader :value

    # Generate a hash based on the fields defined in this type
    #
    # @param request [APeye::Request] the associated request
    # @return [Hash]
    def hash(request: nil)
      self.class.definition.generate_hash_for_fields(@value, request: request)
    end

    # Should this type be included in any output?
    #
    # @param request [APeye::Request]
    # @return [Boolean]
    def include?(request)
      return true if self.class.definition.conditions.empty?

      self.class.definition.conditions.all? do |cond|
        cond.call(@value, request) == true
      end
    end
  end
end
