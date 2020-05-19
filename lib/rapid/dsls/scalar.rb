# frozen_string_literal: true

require 'rapid/dsl'

module Rapid
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
