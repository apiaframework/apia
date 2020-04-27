# frozen_string_literal: true

module APeye
  module DSLs
    class Controller
      def initialize(definition)
        @definition = definition
      end

      def description(description)
        @definition.description = description
      end

      def authenticator(authenticator)
        @definition.authenticator = authenticator
      end
    end
  end
end
