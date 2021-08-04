# frozen_string_literal: true

require 'apia/dsl'
require 'apia/helpers'
require 'apia/errors/scope_not_granted_error'

module Apia
  module DSLs
    class Authenticator < DSL

      def type(type)
        @definition.type = type
      end

      def potential_error(klass, &block)
        if block_given? && klass.is_a?(String)
          id = "#{@definition.id}/#{Helpers.camelize(klass)}"
          klass = Apia::Error.create(id, &block)
        end

        @definition.potential_errors << klass
      end

      def action(&block)
        @definition.action = block
      end

      def scope_validator(&block)
        unless @definition.potential_errors.include?(Apia::ScopeNotGrantedError)
          potential_error Apia::ScopeNotGrantedError
        end

        @definition.scope_validator = block
      end

    end
  end
end
