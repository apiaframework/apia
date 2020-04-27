# frozen_string_literal: true

module APeye
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
          @definition.endpoints[name] = APeye::Endpoint.create(klass_or_name || "#{@definition.name}-#{name}", &block)
        else
          @definition.endpoints[name] = klass_or_name
        end
      end
    end
  end
end
