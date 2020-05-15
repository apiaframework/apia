# frozen_string_literal: true

module Rapid
  module DSLs
    class Scalar

      def initialize(definition)
        @definition = definition
      end

      def name(name)
        @definition.name = name
      end

      def description(value)
        @definition.description = value
      end

      def cast(&block)
        @definition.cast = block
      end

      def parse(&block)
        @definition.parse = block
      end

      def validator(&block)
        @definition.validator = block
      end

    end
  end
end
