# frozen_string_literal: true

require 'rapid/dsl'
require 'rapid/helpers'
require 'rapid/errors/scope_not_granted_error'

module Rapid
  module DSLs
    class Authenticator < DSL

      def type(type)
        @definition.type = type
      end

      def potential_error(klass, &block)
        if block_given? && klass.is_a?(String)
          id = "#{@definition.id}/#{Helpers.camelize(klass)}"
          klass = Rapid::Error.create(id, &block)
        end

        @definition.potential_errors << klass
      end

      def action(&block)
        @definition.action = block
      end

      def scope_validator(&block)
        unless @definition.potential_errors.include?(Rapid::ScopeNotGrantedError)
          potential_error Rapid::ScopeNotGrantedError
        end

        @definition.scope_validator = block
      end

    end
  end
end
