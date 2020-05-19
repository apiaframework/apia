# frozen_string_literal: true

require 'rapid/definition'
require 'rapid/dsls/argument_set'

module Rapid
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
          if argument.is_a?(Rapid::Definitions::Argument)
            argument.validate(errors)
          else
            errors.add self, 'InvalidArgument', "The argument '#{name}' is not an instance of Rapid::Definitions::Argument"
          end
        end
      end

    end
  end
end
