# frozen_string_literal: true

require 'rapid/definition'
require 'rapid/helpers'
require 'rapid/dsls/field'
require 'rapid/definitions/type'
require 'rapid/errors/invalid_scalar_value_error'
require 'rapid/errors/null_field_value_error'

module Rapid
  module Definitions
    class Field < Definition

      attr_accessor :description
      attr_accessor :backend
      attr_accessor :array
      attr_accessor :null
      attr_accessor :condition
      attr_writer :type
      attr_accessor :include

      def initialize(name, id: nil)
        @name = name
        @id = id
      end

      # Return the type of object
      #
      # @return [Class]
      def type
        Type.new(@type)
      end

      # Can the result for thsi field be nil?
      #
      # @return [Boolean]
      def null?
        @null == true
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
      # @param request [Rapid::Request]
      # @return [Boolean]
      def include?(value, request)
        return true if @condition.nil?

        @condition.call(value, request) == true
      end

      # Return a DSL instance for this field
      #
      # @return [Rapid::DSLs::Field]
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
          get_value_from_backend(object)
        else
          get_value_directly_from_object(object, @name)
        end
      end

      # Return an instance of a Type or a Scalar for this field
      #
      # @param object [Object]
      # @return [Object]
      def value(object, request: nil, path: [])
        raw_value = raw_value_from_object(object)

        return nil if raw_value.nil? && null?
        raise Rapid::NullFieldValueError.new(self, object) if raw_value.nil?

        if array? && raw_value.is_a?(Array)
          raw_value.map { |v| type.cast(v, request: request, path: path) }
        else
          type.cast(raw_value, request: request, path: path)
        end
      end

      private

      def get_value_from_backend(object)
        case @backend
        when Symbol
          get_value_directly_from_object(object, @backend)
        when Proc
          @backend.call(object)
        end
      end

      def get_value_directly_from_object(object, name)
        if object.is_a?(Hash)
          object.fetch(name.to_sym) { object[name.to_s] }
        else
          object.public_send(name.to_sym)
        end
      end

    end
  end
end
