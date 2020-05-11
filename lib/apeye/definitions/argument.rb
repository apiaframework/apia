# frozen_string_literal: true

require 'apeye/dsls/argument'
require 'apeye/scalars'

module APeye
  module Definitions
    class Argument
      attr_reader :name
      attr_reader :options
      attr_reader :validations

      def initialize(name, **options)
        @name = name
        @options = options
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
        elsif !(type.respond_to?(:ancestors) && (type.ancestors.include?(APeye::Type) || type.ancestors.include?(APeye::Scalar)))
          errors.add self, 'InvalidType', 'Type must be a class that inherits from APeye::Type or APeye::Scalar'
        end
      end

      # Return the description for this argument
      #
      # @return [String, nil]
      def description
        @options[:description]
      end

      # Return the type of object (either a ArgumentSet or a Scalar) which
      # this argument represents.
      #
      # @return [Class]
      def type
        @type ||= begin
          if @options[:type].is_a?(Symbol) || @options[:type].is_a?(String)
            Scalars::ALL[@options[:type].to_sym]
          else
            @options[:type]
          end
        end
      end

      # Is this argument required?
      #
      # @return [Boolean]
      def required?
        @options[:required] == true
      end

      # Is this an array?
      #
      # @return [Boolean]
      def array?
        @options[:array] == true
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
