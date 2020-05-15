# frozen_string_literal: true

require 'rapid/dsls/argument_set'

module Rapid
  module Definitions
    class ArgumentSet

      attr_accessor :id
      attr_accessor :name
      attr_accessor :description
      attr_reader :arguments

      def initialize(id)
        @id = id
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
