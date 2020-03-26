# frozen_string_literal: true

require 'apeye/dsls/argument'
require 'apeye/scalars'
require 'apeye/errors/manifest_error'

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

      # Return the type of object (either a ArgumentSet or a Scalar) which
      # this argument represents.
      #
      # @return [Class]
      def type
        @type ||= begin
          if @options[:type].is_a?(Symbol) || @options[:type].is_a?(String)
            Scalars::ALL[@options[:type].to_sym] || raise(ManifestError, "Invalid type name '#{@options[:type]}' (valid options are #{Scalars::ALL.keys.join(', ')})")

          elsif @options[:type].ancestors.include?(APeye::Scalar) || @options[:type].ancestors.include?(APeye::ArgumentSet)
            @options[:type]

          else
            raise ManifestError, "Invalid type provided for argument (#{@options[:type]}). Must be a scalar or argument set."
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
      def validate(value)
        @validations.each_with_object([]) do |validation, errors|
          errors << validation[:name] unless validation[:block].call(value)
        end
      end
    end
  end
end
