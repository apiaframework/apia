# frozen_string_literal: true

module APeye
  module Definitions
    module Concerns
      module HasFields
        def fields
          @fields ||= {}
        end

        # Return an array of unique types that are referenced by the
        # fields
        #
        # @return [Set]
        def types
          Set.new(@fields.values.map(&:types).flatten.uniq)
        end

        # Generate a hash for the fields that are defined on this object.
        # It should receive the source object as well as a request
        #
        # @param source [Object, Hash]
        # @param request [APeye::Request]
        # @return [Hash]
        def generate_hash_for_fields(source, request: nil)
          fields.each_with_object({}) do |(_, field), hash|
            next unless field.include?(source, request)

            type_instance = field.value(source)

            if type_instance.nil?
              # If the value is nil, the value is nil
              value = nil

            elsif type_instance.is_a?(APeye::Type)
              next unless type_instance.include?(request)

              # For type values, we want to render a hash
              value = type_instance.hash(request: request)
            else

              # For scaler & enum values, we just want to cast them
              value = type_instance.cast
            end

            hash[field.name.to_s] = value
          end
        end
      end
    end
  end
end
