# frozen_string_literal: true

module APeye
  module DSLs
    class Field
      def initialize(field_definition)
        @field_definition = field_definition
      end

      def backend(&block)
        @field_definition.options[:backend] = block
      end

      def can_be_nil(value)
        @field_definition.options[:nil] = value
      end

      def condition(&block)
        @field_definition.options[:condition] = block
      end
    end
  end
end
