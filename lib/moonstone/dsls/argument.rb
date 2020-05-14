# frozen_string_literal: true

module Moonstone
  module DSLs
    class Argument

      def initialize(definition)
        @definition = definition
      end

      def description(description)
        @definition.description = description
      end

      def validation(name, &block)
        @definition.validations << { name: name, block: block }
      end

      def required(value)
        @definition.required = value
      end

      def array(value)
        @definition.array = value
      end

    end
  end
end
