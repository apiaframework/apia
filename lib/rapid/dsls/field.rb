# frozen_string_literal: true

module Rapid
  module DSLs
    class Field

      def initialize(definition)
        @definition = definition
      end

      def description(value)
        @definition.description = value
      end

      def backend(&block)
        @definition.backend = block
      end

      def can_be_nil(value)
        @definition.can_be_nil = value
      end

      def array(value)
        @definition.array = value
      end

      def condition(&block)
        @definition.condition = block
      end

    end
  end
end
