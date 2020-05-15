# frozen_string_literal: true

require 'rapid/helpers'

module Rapid
  module DSLs
    class Authenticator

      def initialize(definition)
        @definition = definition
      end

      def name(name)
        @definition.name = name
      end

      def description(description)
        @definition.description = description
      end

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
