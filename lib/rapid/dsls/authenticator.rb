# frozen_string_literal: true

require 'rapid/dsl'
require 'rapid/helpers'

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

    end
  end
end
