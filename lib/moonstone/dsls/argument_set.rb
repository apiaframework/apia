# frozen_string_literal: true

require 'moonstone/definitions/argument'
require 'moonstone/helpers'

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
        argument = Definitions::Argument.new(name, id: "#{@definition.id}/#{Helpers.camelize(name.to_s)}Argument")

        if type.is_a?(Array)
          argument.type = type[0]
          argument.array = true
        else
          argument.type = type
          argument.array = false
        end

        argument.required = options[:required] if options.key?(:required)

        argument.dsl.instance_eval(&block) if block_given?

        @definition.arguments[name.to_sym] = argument
      end

    end
  end
end
