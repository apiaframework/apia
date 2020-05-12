# frozen_string_literal: true

require 'moonstone/dsls/concerns/has_fields'

module Moonstone
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

      def argument(*args, &block)
        @definition.argument_set.argument(*args, &block)
      end

      def action(&block)
        @definition.action = block
      end

      def http_method(status)
        @definition.http_method = status
      end

      def http_status(status)
        @definition.http_status = status
      end
    end
  end
end
