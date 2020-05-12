# frozen_string_literal: true

module Moonstone
  module DSLs
    class Authenticator
      def initialize(definition)
        @definition = definition
      end

      def name_override(name)
        @definition.name = name
      end

      def type(type)
        @definition.type = type
      end

      def potential_error(klass_or_name, &block)
        @definition.potential_errors << if block_given?
                                          Moonstone::Error.create(klass_or_name, &block)
                                        else
                                          klass_or_name
                                       end
      end

      def action(&block)
        @definition.action = block
      end
    end
  end
end
