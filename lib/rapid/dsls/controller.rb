# frozen_string_literal: true

require 'rapid/endpoint'

module Rapid
  module DSLs
    class Controller

      def initialize(definition)
        @definition = definition
      end

      def name(name)
        @definition.name = name
      end

      def description(description)
        @definition.description = description
      end

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

    end
  end
end
