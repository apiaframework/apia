# frozen_string_literal: true

module Moonstone
  module DSLs
    class Enum
      def initialize(definition)
        @definition = definition
      end

      def name_override(name)
        @definition.name = name
      end

      def description(value)
        @definition.description = value
      end

      def value(key, description = nil)
        @definition.values[key.to_s] = { description: description }
      end

      def cast(&block)
        @definition.cast = block
      end
    end
  end
end
