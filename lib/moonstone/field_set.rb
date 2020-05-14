# frozen_string_literal: true

require 'moonstone/scalar'
require 'moonstone/type'
require 'moonstone/enum'

module Moonstone
  class FieldSet < Hash

    VALID_OBJECTS_FOR_TYPE = [Scalar, Type, Enum].freeze

    def self.can_use_as_type?(object)
      return false unless object.respond_to?(:ancestors)

      object.ancestors.any? { |a| VALID_OBJECTS_FOR_TYPE.include?(a) }
    end

    def add(field)
      self[field.name] = field
    end

    def validate(errors, object)
      each_value do |field|
        unless self.class.can_use_as_type?(field.type)
          errors.add object, :invalid_field_type, "Type for field #{field.name} must be a scalar or Moonstone::Type"
        end
      end
    end

    # Generate a hash for the fields that are defined on this object.
    # It should receive the source object as well as a request
    #
    # @param source [Object, Hash]
    # @param request [Moonstone::Request]
    # @return [Hash]
    def generate_hash(source, request: nil)
      each_with_object({}) do |(_, field), hash|
        next unless field.include?(source, request)

        type_instance = field.value(source)

        if type_instance.is_a?(Array)
          value = type_instance.each_with_object([]) do |ti, array|
            v = cast_type_instance(ti, request: request)
            array << v unless v == :skip
          end
        else
          value = cast_type_instance(type_instance, request: request)
          next if value == :skip
        end

        hash[field.name.to_s] = value
      end
    end

    private

    def cast_type_instance(type_instance, request: nil)
      if type_instance.nil?
        # If the value is nil, the value is nil
        value = nil

      elsif type_instance.is_a?(Moonstone::Type)
        return :skip unless type_instance.include?(request)

        # For type values, we want to render a hash
        value = type_instance.hash(request: request)
      else

        # For scaler & enum values, we just want to cast them
        value = type_instance.cast
      end
    end

  end
end
