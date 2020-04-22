# frozen_string_literal: true

module APeye
  module DSLs
    class Authenticator
      def initialize(authenticator)
        @authenticator = authenticator
      end

      def name_override(name)
        @authenticator.name = name
      end

      def type(type)
        @authenticator.type = type
      end

      def potential_error(error)
        @authenticator.potential_errors << error
      end

      def action(&block)
        @authenticator.action = block
      end
    end
  end
end
