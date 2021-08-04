# frozen_string_literal: true

require 'apia/definitions/type'

module Apia
  module Definitions
    class PolymorphOption

      attr_reader :id
      attr_reader :name
      attr_reader :matcher

      def initialize(id, name, type: nil, matcher: nil)
        @id = id
        @name = name
        @type = type
        @matcher = matcher
      end

      def type
        Type.new(@type)
      end

      def matches?(value)
        return false if @matcher.nil?

        @matcher.call(value) == true
      end

      def cast(value, request: nil, path: [])
        {
          type: @name.to_s,
          value: type.cast(value, request: request, path: path)
        }
      end

      def validate(errors)
        if @type.nil?
          errors.add self, 'MissingType', "Type for #{name} is missing"
        elsif !type.usable_for_field?
          errors.add self, 'InvalidType', "Type for #{name} must a scalar, polymorph, object or enum "
        end

        unless @matcher.is_a?(Proc)
          errors.add self, 'MissingMatcher', "A matcher must be provided for all options (missing for #{name})"
        end

        true
      end

    end
  end
end
