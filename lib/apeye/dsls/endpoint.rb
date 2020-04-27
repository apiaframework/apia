# frozen_string_literal: true

require 'apeye/dsls/concerns/has_fields'

module APeye
  module DSLs
    class Endpoint
      include DSLs::Concerns::HasFields

      def initialize(definition)
        @definition = definition
      end

      def label(value)
        @definition.label = value
      end

      def description(value)
        @definition.description = value
      end

      def authenticator(klass)
        @definition.authenticator = klass
      end

      def potential_error(error)
        @definition.potential_errors << error
      end

      def endpoint(&block)
        @definition.endpoint = block
      end
    end
  end
end
