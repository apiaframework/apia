# frozen_string_literal: true

module Moonstone
  module Definitions
    module Concerns
      module HasFields
        def fields
          @fields ||= {}
        end

        # Add a new field
        #
        # @param field [Moonstone::Definitions::Field]
        # @return [Moonstone::Definitions::Field]
        def add_field(field)
          fields[field.name] = field
        end

        # Generate a hash for the fields that are defined on this object.
        # It should receive the source object as well as a request
        #
        # @param source [Object, Hash]
        # @param request [Moonstone::Request]
        # @return [Hash]
        def generate_hash_for_fields(source, request: nil)
          fields.each_with_object({}) do |(_, field), hash|
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
  end
end
