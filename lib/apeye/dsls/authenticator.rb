# frozen_string_literal: true

module APeye
  module DSLs
    class Authenticator
      def initialize(definition)
        @definition = definition
      end

      def name_override(name)
        @definition.name = name
      end

      def type(type)
        @definition.type = type
      end

      def potential_error(error)
        @definition.potential_errors << error
      end

      def action(&block)
        @definition.action = block
      end
    end
  end
end
