# frozen_string_literal: true

require 'rapid/dsl'

module Rapid
  module DSLs
    class Argument < DSL

      def validation(name, &block)
        @definition.validations << { name: name, block: block }
      end

      def required(value)
        @definition.required = value
      end

      def array(value)
        @definition.array = value
      end

      def default(value)
        @definition.default = value
      end

    end
  end
end
