# frozen_string_literal: true

module APeye
  module DSLs
    class Error
      def initialize(definition)
        @definition = definition
      end

      def code(code)
        @definition.code = code
      end

      def http_status(http_status)
        @definition.http_status = http_status
      end

      def description(description)
        @definition.description = description
      end
    end
  end
end
