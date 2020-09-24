# frozen_string_literal: true

require 'rapid/dsl'
require 'rapid/endpoint'

module Rapid
  module DSLs
    class Controller < DSL

      def authenticator(klass = nil, &block)
        if block_given?
          id = "#{@definition.id}/#{Helpers.camelize(klass) || 'Authenticator'}"
          klass = Rapid::Authenticator.create(id, &block)
        end

        @definition.authenticator = klass
      end

      def endpoint(name, klass = nil, &block)
        if block_given?
          id = "#{@definition.id}/#{klass || Helpers.camelize(name) + 'Endpoint'}"
          klass = Rapid::Endpoint.create(id, &block)
        end

        @definition.endpoints[name.to_sym] = klass
      end

      def helper(name, &block)
        @definition.helpers[name] = block
      end

    end
  end
end
