# frozen_string_literal: true

require 'apia/definition'
require 'apia/dsls/authenticator'

module Apia
  module Definitions
    class Authenticator < Definition

      TYPES = [:bearer, :anonymous].freeze

      attr_accessor :type
      attr_accessor :action
      attr_accessor :scope_validator
      attr_reader :potential_errors

      def setup
        @id = id
        @potential_errors = []
      end

      def dsl
        @dsl ||= DSLs::Authenticator.new(self)
      end

      def validate(errors)
        if @type.nil?
          errors.add self, 'MissingType', 'A type must be defined for authenticators'
        elsif !TYPES.include?(@type)
          errors.add self, 'InvalidType', "The type must be one of #{TYPES.join(', ')} (was: #{@type.inspect})"
        end

        if @action && !@action.is_a?(Proc)
          errors.add self, 'InvalidAction', 'The action provided must be a Proc'
        end

        @potential_errors.each_with_index do |error, index|
          unless error.respond_to?(:ancestors) && error.ancestors.include?(Apia::Error)
            errors.add self, 'InvalidPotentialError', "Potential error at index #{index} must be a class that inherits from Apia::Error"
          end
        end
      end

    end
  end
end
