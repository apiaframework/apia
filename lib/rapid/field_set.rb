# frozen_string_literal: true

require 'rapid/helpers'
require 'rapid/scalar'
require 'rapid/object'
require 'rapid/enum'

module Rapid
  class FieldSet < Hash

    def add(field)
      self[field.name] = field
    end

    def validate(errors, object)
      each_value do |field|
        unless field.type.usable_for_field?
          errors.add object, :invalid_field_type, "Type for field #{field.name} must be a scalar, enum or object"
        end
      end
    end

    # Generate a hash for the fields that are defined on this object.
    # It should receive the source object as well as a request
    #
    # @param source [Object, Hash]
    # @param request [Rapid::Request]
    # @return [Hash]
    def generate_hash(source, request: nil)
      each_with_object({}) do |(_, field), hash|
        next unless field.include?(source, request)

        value = field.value(source, request: request)
        next if value == :skip

        hash[field.name.to_s] = value
      end
    end

  end
end
