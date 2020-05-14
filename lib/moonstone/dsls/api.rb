# frozen_string_literal: true

require 'moonstone/helpers'

module Moonstone
  module DSLs
    class API

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
          klass = Moonstone::Authenticator.create(id, &block)
        end

        @definition.authenticator = klass
      end

      def controller(name, klass = nil, &block)
        if block_given? && klass.nil?
          id = "#{@definition.id}/#{Helpers.camelize(name)}Controller"
          klass = Moonstone::Controller.create(id, &block)
        end

        @definition.controllers[name.to_sym] = klass
      end

    end
  end
end
