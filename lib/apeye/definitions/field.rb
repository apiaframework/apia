# frozen_string_literal: true

require 'apeye/dsls/field'
require 'apeye/errors/invalid_type_error'
require 'apeye/errors/null_field_value_error'
require 'apeye/scalars'

module APeye
  module Definitions
    class Field
      attr_reader :name
      attr_reader :options

      def initialize(name, **options)
        @name = name
        @options = options
      end

      # Return the type of object (either a Type or a Scalar) which
      # this field represents.
      def type
        @type ||= begin
          if @options[:type].is_a?(Symbol) || @options[:type].is_a?(String)
            Scalars::ALL[@options[:type].to_sym]
          else
            @options[:type]
          end
        end
      end

      def can_be_nil?
        @options[:nil] == true
      end

      def array?
        @options[:array] == true
      end

      def include?(value, request)
        return true if @options[:condition].nil?

        @options[:condition].call(value, request)
      end

      def dsl
        @dsl ||= DSLs::Field.new(self)
      end

      # Return the backend value from the given object based on the
      # rules that exist for this field.
      #
      # @param object [Object]
      # @return [Object]
      def raw_value_from_object(object)
        if @options[:backend]
          @options[:backend].call(object)
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
        raise APeye::NullFieldValueError, self if raw_value.nil?

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
          raise APeye::InvalidTypeError.new(self, value)
        end

        type_instance
      end
    end
  end
end
