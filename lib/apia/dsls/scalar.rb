# frozen_string_literal: true

require 'apia/dsl'

module Apia
  module DSLs
    class Scalar < DSL

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
