# frozen_string_literal: true

require 'rapid/dsl'
require 'rapid/definitions/argument'
require 'rapid/helpers'

module Rapid
  module DSLs
    class ArgumentSet < DSL

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
