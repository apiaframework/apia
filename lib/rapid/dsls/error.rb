# frozen_string_literal: true

require 'rapid/dsl'
require 'rapid/dsls/concerns/has_fields'

module Rapid
  module DSLs
    class Error < DSL

      include DSLs::Concerns::HasFields

      def code(code)
        @definition.code = code
      end

      def http_status(http_status)
        @definition.http_status = http_status
      end

    end
  end
end
