# frozen_string_literal: true

require 'moonstone/dsls/argument_set'

module Moonstone
  module Definitions
    class ArgumentSet
      attr_accessor :id
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
          unless argument.is_a?(Moonstone::Definitions::Argument)
            errors.add self, 'InvalidArgument', "The argument '#{name}' is not an instance of Moonstone::Definitions::Argument"
          end
        end
      end
    end
  end
end
