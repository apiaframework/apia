# frozen_string_literal: true

require 'moonstone/endpoint'

module Moonstone
  module DSLs
    class Controller
      def initialize(definition)
        @definition = definition
      end

      def description(description)
        @definition.description = description
      end

      def authenticator(authenticator)
        @definition.authenticator = authenticator
      end

      def endpoint(name, klass_or_name = nil, &block)
        if block_given?
          @definition.endpoints[name] = Moonstone::Endpoint.create(klass_or_name || "#{@definition.id}.#{name}", &block)
        else
          @definition.endpoints[name] = klass_or_name
        end
      end
    end
  end
end
