# frozen_string_literal: true

require 'rapid/dsls/concerns/has_fields'

module Rapid
  module DSLs
    class Error

      include DSLs::Concerns::HasFields

      def initialize(definition)
        @definition = definition
      end

      def name(name)
        @definition.name = name
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
