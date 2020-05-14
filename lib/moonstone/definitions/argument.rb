# frozen_string_literal: true

require 'moonstone/dsls/argument'
require 'moonstone/scalars'

module Moonstone
  module Definitions
    class Argument

      attr_accessor :id
      attr_reader :name
      attr_reader :options
      attr_reader :validations
      attr_accessor :description
      attr_accessor :required
      attr_accessor :array
      attr_accessor :type

      def initialize(name, id: nil)
        @name = name
        @id = id
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

        if type.nil?
          errors.add self, 'MissingType', 'Arguments must have a type'
        elsif !(type.respond_to?(:ancestors) && (type.ancestors.include?(Moonstone::ArgumentSet) || type.ancestors.include?(Moonstone::Enum) || type.ancestors.include?(Moonstone::Scalar)))
          errors.add self, 'InvalidType', 'Type must be a class that inherits from Moonstone::ArgumentSet, Moonstone::Enum or Moonstone::Scalar'
        end
      end

      # Return the type of object (either a ArgumentSet or a Scalar) which
      # this argument represents.
      #
      # @return [Class]
      def type
        if @type.is_a?(Symbol) || @type.is_a?(String)
          Scalars::ALL[@type.to_sym]
        else
          @type
        end
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
