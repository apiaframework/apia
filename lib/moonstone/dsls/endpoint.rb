# frozen_string_literal: true

require 'moonstone/dsls/concerns/has_fields'

module Moonstone
  module DSLs
    class Endpoint

      include DSLs::Concerns::HasFields

      def initialize(definition)
        @definition = definition
      end

      def name(name)
        @definition.name = name
      end

      def description(value)
        @definition.description = value
      end

      def authenticator(klass = nil, &block)
        if block_given?
          id = "#{@definition.id}/#{Helpers.camelize(klass) || 'Authenticator'}"
          klass = Moonstone::Authenticator.create(id, &block)
        end

        @definition.authenticator = klass
      end

      def potential_error(klass, &block)
        if block_given? && klass.is_a?(String)
          id = "#{@definition.id}/#{Helpers.camelize(klass)}"
          klass = Moonstone::Error.create(id, &block)
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
