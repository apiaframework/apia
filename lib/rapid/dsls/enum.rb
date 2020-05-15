# frozen_string_literal: true

module Rapid
  module DSLs
    class Enum

      def initialize(definition)
        @definition = definition
      end

      def name(name)
        @definition.name = name
      end

      def description(value)
        @definition.description = value
      end

      def value(name, description = nil)
        @definition.values[name.to_s] = { name: name.to_s, description: description }
      end

      def cast(&block)
        @definition.cast = block
      end

    end
  end
end
