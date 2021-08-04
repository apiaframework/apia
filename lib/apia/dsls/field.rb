# frozen_string_literal: true

require 'apia/dsl'

module Apia
  module DSLs
    class Field < DSL

      def backend(&block)
        @definition.backend = block
      end

      def null(value)
        @definition.null = value
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
