# frozen_string_literal: true

module APeye
  module DSLs
    class Error
      def initialize(error)
        @error = error
      end

      def code(code)
        @error.code = code
      end

      def http_status(http_status)
        @error.http_status = http_status
      end

      def description(description)
        @error.description = description
      end
    end
  end
end
