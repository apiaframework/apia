# frozen_string_literal: true

require 'moonstone/dsls/field'
require 'moonstone/errors/invalid_type_error'
require 'moonstone/errors/null_field_value_error'
require 'moonstone/scalars'

module Moonstone
  module Definitions
    class Field

      attr_reader :name
      attr_accessor :description
      attr_accessor :backend
      attr_accessor :array
      attr_accessor :can_be_nil
      attr_accessor :condition
      attr_accessor :type

      def initialize(name)
        @name = name
      end

      # Return the type of object (either a Type or a Scalar) which
      # this field represents.
      #
      # @return [Class]
      def type
        if @type.is_a?(Symbol) || @type.is_a?(String)
          Scalars::ALL[@type.to_sym]
        else
          @type
        end
      end

      # Can the result for thsi field be nil?
      #
      # @return [Boolean]
      def can_be_nil?
        @can_be_nil == true
      end

      # Is the result from this field expected to be an array?
      #
      # @return [Boolean]
      def array?
        @array == true
      end

      # Should this field be inclued for the given value and request
      #
      # @param value [Object]
      # @param request [Moonstone::Request]
      # @return [Boolean]
      def include?(value, request)
        return true if @condition.nil?

        @condition.call(value, request) == true
      end

      # Return a DSL instance for this field
      #
      # @return [Moonstone::DSLs::Field]
      def dsl
        @dsl ||= DSLs::Field.new(self)
      end

      # Return the backend value from the given object based on the
      # rules that exist for this field.
      #
      # @param object [Object]
      # @return [Object]
      def raw_value_from_object(object)
        if @backend
          @backend.call(object)
        elsif object.is_a?(Hash)
          object[@name.to_sym] || object[@name.to_s]
        else
          object.public_send(@name.to_sym)
        end
      end

      # Return an instance of a Type or a Scalar for this field
      #
      # @param object [Object]
      # @return [Object]
      def value(object)
        raw_value = raw_value_from_object(object)

        return nil if raw_value.nil? && can_be_nil?
        raise Moonstone::NullFieldValueError, self if raw_value.nil?

        if array? && raw_value.is_a?(Array)
          raw_value.map { |v| create_type_instance_from_raw_value(v) }
        else
          create_type_instance_from_raw_value(raw_value)
        end
      end

      private

      def create_type_instance_from_raw_value(value)
        type_instance = type.new(value)
        if type_instance.is_a?(Scalar) && !type_instance.valid?
          raise Moonstone::InvalidTypeError.new(self, value)
        end

        type_instance
      end

    end
  end
end
