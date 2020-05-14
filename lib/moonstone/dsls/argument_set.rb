# frozen_string_literal: true

require 'moonstone/definitions/argument'

module Moonstone
  module DSLs
    class ArgumentSet

      def initialize(definition)
        @definition = definition
      end

      def name(name)
        @definition.name = name
      end

      def description(value)
        @definition.description = value
      end

      def argument(name, type: nil, **options, &block)
        if type.is_a?(Array)
          options[:type] = type[0]
          options[:array] = true
        else
          options[:type] = type
          options[:array] = false
        end

        argument = Definitions::Argument.new(name, **options)
        argument.dsl.instance_eval(&block) if block_given?

        @definition.arguments[name.to_sym] = argument
      end

    end
  end
end
