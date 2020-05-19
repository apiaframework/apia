# frozen_string_literal: true

require 'rapid/dsl'
require 'rapid/dsls/concerns/has_fields'

module Rapid
  module DSLs
    class Endpoint < DSL

      include DSLs::Concerns::HasFields

      def authenticator(klass = nil, &block)
        if block_given?
          id = "#{@definition.id}/#{Helpers.camelize(klass) || 'Authenticator'}"
          klass = Rapid::Authenticator.create(id, &block)
        end

        @definition.authenticator = klass
      end

      def potential_error(klass, &block)
        if block_given? && klass.is_a?(String)
          id = "#{@definition.id}/#{Helpers.camelize(klass)}"
          klass = Rapid::Error.create(id, &block)
        end

        @definition.potential_errors << klass
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
