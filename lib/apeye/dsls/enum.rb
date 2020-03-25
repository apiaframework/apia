# frozen_string_literal: true

module APeye
  module DSLs
    class Enum
      def initialize(enum_definition)
        @enum_definition = enum_definition
      end

      def enum_name(name)
        @enum_definition.name = name
      end

      def description(value)
        @enum_definition.description = value
      end

      def value(key, description = nil)
        @enum_definition.values[key.to_s] = { description: description }
      end

      def cast(&block)
        @enum_definition.cast = block
      end
    end
  end
end
