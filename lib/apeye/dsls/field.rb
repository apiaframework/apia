# frozen_string_literal: true

module APeye
  module DSLs
    class Field
      def initialize(definition)
        @definition = definition
      end

      def backend(&block)
        @definition.options[:backend] = block
      end

      def can_be_nil(value)
        @definition.options[:nil] = value
      end

      def condition(&block)
        @definition.options[:condition] = block
      end
    end
  end
end
