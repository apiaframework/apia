# frozen_string_literal: true

require 'rapid/dsl'
require 'rapid/helpers'

module Rapid
  module DSLs
    class API < DSL

      def authenticator(klass = nil, &block)
        if block_given?
          id = "#{@definition.id}/#{Helpers.camelize(klass) || 'Authenticator'}"
          klass = Rapid::Authenticator.create(id, &block)
        end

        @definition.authenticator = klass
      end

      def exception_handler(block_var = nil, &block)
        @definition.exception_handlers.add(block_var, &block)
      end

      def routes(&block)
        @definition.route_set.dsl.instance_eval(&block) if block_given?
      end

    end
  end
end
