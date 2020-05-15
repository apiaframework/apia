# frozen_string_literal: true

module Rapid
  module Definitions
    class Type

      def initialize(type)
        @type = type
      end

      def id
        klass&.definition&.id
      end

      def klass
        if @type.is_a?(Symbol) || @type.is_a?(String)
          Scalars.fetch(@type.to_sym)
        else
          @type
        end
      end

      # Can this type actually be used?
      #
      # @return [Boolean]
      def usable_for_field?
        scalar? || object? || enum? || polymorph?
      end

      # Can this type be used for an argument?
      #
      # @return [Boolean]
      def usable_for_argument?
        scalar? || enum? || argument_set?
      end

      # Cast the given value into an response that can be sent to the
      # consumer.
      #
      # @param value [Object, nil]
      # @param request [Rapid::Request, nil]
      # @return [Object, nil]
      def cast(value, request: nil)
        return nil if value.nil?

        if scalar? || enum?
          # If this is a scalar or an enum, we're going to just return the
          # value that they return. There's nothing complicated about them
          # and they return scalars.
          klass.cast(value)

        elsif object?
          # If this field returns an object, we'll go ahead and generate
          # the hash for the object at this point.
          object = klass.new(value)

          # If this item shouldn't be included. we'll return :skip which
          # will instruct the field set not to include it at all.
          return :skip unless object.include?(request)

          # Otherwise, we'll return the hash
          object.hash(request: request)

        elsif polymorph?
          # If the type is a polymorph and this value
          option = klass.option_for_value(value)
          option.cast(value)

        end
      end

      # Does this field return a scalar?
      #
      # @return [Boolean]
      def argument_set?
        klass&.ancestors&.include?(Rapid::ArgumentSet)
      end

      # Does this field return a scalar?
      #
      # @return [Boolean]
      def scalar?
        klass&.ancestors&.include?(Rapid::Scalar)
      end

      # Does this field return an enum?
      #
      # @return [Boolean]
      def enum?
        klass&.ancestors&.include?(Rapid::Enum)
      end

      # Does this field return an object?
      #
      # @return [Boolean]
      def object?
        klass&.ancestors&.include?(Rapid::Object)
      end

      # Does this field return a polymorph?
      #
      # @return [Boolean]
      def polymorph?
        klass&.ancestors&.include?(Rapid::Polymorph)
      end

    end
  end
end
