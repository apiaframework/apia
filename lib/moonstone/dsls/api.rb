# frozen_string_literal: true

module Moonstone
  module DSLs
    class API
      def initialize(definition)
        @definition = definition
      end

      def authenticator(klass_or_name = nil, &block)
        @definition.authenticator = if block_given?
                                      Moonstone::Authenticator.create(klass_or_name || "#{@definition.id}Authenticator", &block)
                                    else
                                      klass_or_name
                                    end
      end

      def controller(name, klass = nil, &block)
        @definition.controllers[name.to_sym] = if block_given?
                                                 Moonstone::Controller.create("AnonymousController.#{name}", &block)
                                               else
                                                 klass
                                               end
      end
    end
  end
end
