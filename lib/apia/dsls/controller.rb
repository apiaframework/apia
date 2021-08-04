# frozen_string_literal: true

require 'apia/dsl'
require 'apia/endpoint'

module Apia
  module DSLs
    class Controller < DSL

      def authenticator(klass = nil, &block)
        if block_given?
          id = "#{@definition.id}/#{Helpers.camelize(klass) || 'Authenticator'}"
          klass = Apia::Authenticator.create(id, &block)
        end

        @definition.authenticator = klass
      end

      def endpoint(name, klass = nil, &block)
        if block_given?
          id = "#{@definition.id}/#{klass || Helpers.camelize(name) + 'Endpoint'}"
          klass = Apia::Endpoint.create(id, &block)
        end

        @definition.endpoints[name.to_sym] = klass
      end

      def helper(name, &block)
        @definition.helpers[name] = block
      end

    end
  end
end
