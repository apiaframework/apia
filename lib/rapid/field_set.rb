# frozen_string_literal: true

require 'rapid/helpers'
require 'rapid/scalar'
require 'rapid/object'
require 'rapid/enum'

module Rapid
  class FieldSet < Hash

    # Add a new field to the fieldset
    #
    # @param field [Rapid::Field]
    # @return [Rapid::Field]
    def add(field)
      self[field.name] = field
    end

    # Validate this field set and add errors as appropriate
    #
    # @param errors [Rapid::ManifestErrors]
    # @param object [Object]
    # @return [void]
    def validate(errors, object)
      each_value do |field|
        unless field.type.usable_for_field?
          errors.add object, 'InvalidFieldType', "Type for field #{field.name} must be a scalar, enum or object"
        end
      end
    end

    # Generate a hash for the fields that are defined on this object.
    # It should receive the source object as well as a request
    #
    # @param source [Object, Hash]
    # @param request [Rapid::Request]
    # @param only [Array]
    # @return [Hash]
    def generate_hash(source, request: nil, path: [])
      each_with_object({}) do |(_, field), hash|
        next unless field.include?(source, request)

        field_path = path + [field]
        next if request&.field_spec && !request.field_spec.include_field?(field_path)

        value = field.value(source, request: request, path: field_path)
        next if value == :skip

        hash[field.name.to_sym] = value
      end
    end

    # Generate a default field spec for this field set based on the values
    # provided for the include option.
    #
    # @return [FieldSpec]
    def spec
      @spec ||= begin
        spec = each_with_object([]) do |(key, field), array|
          next if field.include == false

          if field.include.is_a?(::String)
            array << "#{key}[#{field.include}]"
          elsif field.type.object? || field.type.polymorph?
            array << "#{key}[*]"
          else
            array << key
          end
        end.join(',')
        FieldSpec.parse(spec)
      end
    end

  end
end
