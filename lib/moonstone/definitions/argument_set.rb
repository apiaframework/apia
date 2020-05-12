# frozen_string_literal: true

require 'moonstone/dsls/argument_set'

module Moonstone
  module Definitions
    class ArgumentSet
      attr_accessor :name
      attr_accessor :description
      attr_reader :arguments

      def initialize(name)
        @name = name
        @arguments = {}
      end

      def dsl
        @dsl ||= DSLs::ArgumentSet.new(self)
      end

      def validate(errors)
        unless @name.to_s =~ /\A[a-z0-9\-\_]+\z/i
          errors.add self, 'InvalidName', "The name (#{@name}) provided must only contain letters, numbers, underscores and hyphens"
        end

        @arguments.each do |name, argument|
          unless argument.is_a?(Moonstone::Definitions::Argument)
            errors.add self, 'InvalidArgument', "The argument '#{name}' is not an instance of Moonstone::Definitions::Argument"
          end
        end
      end
    end
  end
end
