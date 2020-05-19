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

      def controller(name, klass = nil, &block)
        if block_given? && klass.nil?
          id = "#{@definition.id}/#{Helpers.camelize(name)}Controller"
          klass = Rapid::Controller.create(id, &block)
        end

        @definition.controllers[name.to_sym] = klass
      end

    end
  end
end
