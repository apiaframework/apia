# frozen_string_literal: true

require 'rapid/definition'
require 'rapid/dsls/argument'
require 'rapid/helpers'

module Rapid
  module Definitions
    class Argument < Definition

      attr_reader :options
      attr_reader :validations
      attr_accessor :required
      attr_accessor :array
      attr_accessor :type

      def initialize(name, id: nil)
        @id = id
        @name = name
        @validations = []
      end

      def dsl
        @dsl ||= DSLs::Argument.new(self)
      end

      def validate(errors)
        if @name.nil?
          errors.add self, 'MissingName', 'Arguments must have a name'
        elsif @name.to_s !~ /\A[a-z0-9\-\_]+\z/
          errors.add self, 'InvalidName', 'Argument name must only include letters, numbers, hyphens and underscores'
        end

        if @type.nil?
          errors.add self, 'MissingType', 'Arguments must have a type'
        elsif !type.usable_for_argument?
          errors.add self, 'InvalidType', 'Type must be an argument set, scalar or enum'
        end
      end

      # Return the type of object (either a ArgumentSet or a Scalar) which
      # this argument represents.
      #
      # @return [Class]
      def type
        Type.new(@type)
      end

      # Is this argument required?
      #
      # @return [Boolean]
      def required?
        @required == true
      end

      # Is this an array?
      #
      # @return [Boolean]
      def array?
        @array == true
      end

      # Validate a given value through all validations and
      # return an array of all errors
      #
      # @param value [Object]
      # @return [Array]
      def validate_value(value)
        @validations.each_with_object([]) do |validation, errors|
          errors << validation[:name] unless validation[:block].call(value)
        end
      end

    end
  end
end
