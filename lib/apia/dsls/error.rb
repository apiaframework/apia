# frozen_string_literal: true

require 'apia/dsl'
require 'apia/dsls/concerns/has_fields'

module Apia
  module DSLs
    class Error < DSL

      include DSLs::Concerns::HasFields

      def code(code)
        @definition.code = code
      end

      def http_status(http_status)
        @definition.http_status = http_status
      end

      def catch_exception(klass, &block)
        @definition.catchable_exceptions[klass] = block
      end

    end
  end
end
