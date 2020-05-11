# frozen_string_literal: true

module APeye
  module DSLs
    class API
      def initialize(definition)
        @definition = definition
      end

      def name_override(name)
        @definition.name = name
      end

      def authenticator(klass_or_name = nil, &block)
        @definition.authenticator = if block_given?
                                      APeye::Authenticator.create(klass_or_name || "#{@definition.name}Authenticator", &block)
                                    else
                                      klass_or_name
                                    end
      end

      def controller(name, klass = nil, &block)
        @definition.controllers[name.to_sym] = if block_given?
                                                 APeye::Controller.create("AnonymousController.#{name}", &block)
                                               else
                                                 klass
                                               end
      end
    end
  end
end
