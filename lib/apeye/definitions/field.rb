# frozen_string_literal: true

require 'apeye/dsls/field'
require 'apeye/errors/invalid_type_error'
require 'apeye/errors/null_field_value_error'

module APeye
  module Definitions
    class Field
      attr_reader :name
      attr_reader :options

      def initialize(name, **options)
        @name = name
        @options = options
      end

      def type
        @type ||= begin
          if @options[:type].is_a?(Symbol) || @options[:type].is_a?(String)
            require 'apeye/types'
            Types::ALL[@options[:type].to_sym]
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

      def dsl
        @dsl ||= DSLs::Field.new(self)
      end

      def cast(value)
        return nil if value.nil? && can_be_nil?

        raise NullFieldValueError, self if value.nil?

        if array?
          value.map { |v| value_via_type(v) }
        else
          value_via_type(value)
        end
      end

      def value_from_object(object)
        value = if @options[:backend]
                  @options[:backend].call(object)
                elsif object.is_a?(Hash)
                  object[@name.to_sym] || object[@name.to_s]
                else
                  object.public_send(@name.to_sym)
                end
        cast(value)
      end

      private

      def value_via_type(value)
        type_instance = type.new(value)
        raise InvalidTypeError.new(self, value) unless type_instance.valid?

        type_instance.cast
      end
    end
  end
end
