# frozen_string_literal: true

require 'apia/definition'
require 'apia/error_set'
require 'apia/dsls/argument_set'

module Apia
  module Definitions
    class ArgumentSet < Definition

      attr_reader :arguments

      def setup
        @arguments = {}
      end

      def dsl
        @dsl ||= DSLs::ArgumentSet.new(self)
      end

      def validate(errors)
        @arguments.each do |name, argument|
          if argument.is_a?(Apia::Definitions::Argument)
            argument.validate(errors)
          else
            errors.add self, 'InvalidArgument', "The argument '#{name}' is not an instance of Apia::Definitions::Argument"
          end
        end
      end

    end
  end
end
