# frozen_string_literal: true

module APeye
  module DSLs
    class API
      def initialize(definition)
        @definition = definition
      end

      def name_override(name)
        @definition.name = name
      end

      def authenticator(klass)
        @definition.authenticators << klass
      end
    end
  end
end
