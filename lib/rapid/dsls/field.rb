# frozen_string_literal: true

require 'rapid/dsl'

module Rapid
  module DSLs
    class Field < DSL

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
