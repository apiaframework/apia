# frozen_string_literal: true

require 'moonstone/scalar'
require 'moonstone/object'
require 'moonstone/enum'

module Moonstone
  class FieldSet < Hash

    def self.can_use_as_type?(object)
      return false unless object.respond_to?(:ancestors)

      object.ancestors.any? { |a| [Moonstone::Scalar, Moonstone::Object, Moonstone::Enum].include?(a) }
    end

    def add(field)
      self[field.name] = field
    end

    def validate(errors, object)
      each_value do |field|
        unless self.class.can_use_as_type?(field.type)
          errors.add object, :invalid_field_type, "Type for field #{field.name} must be a scalar, enum or object"
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
        nil
      elsif type_instance.is_a?(Moonstone::Object)
        return :skip unless type_instance.include?(request)

        type_instance.hash(request: request)
      elsif type_instance.is_a?(Moonstone::Enum)
        type_instance.cast
      else
        type_instance
      end
    end

  end
end
