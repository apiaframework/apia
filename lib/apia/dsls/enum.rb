# frozen_string_literal: true

require 'apia/dsl'

module Apia
  module DSLs
    class Enum < DSL

      def value(name, description = nil)
        @definition.values[name.to_s] = { name: name.to_s, description: description }
      end

      def cast(&block)
        @definition.cast = block
      end

    end
  end
end
