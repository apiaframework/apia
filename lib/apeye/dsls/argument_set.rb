# frozen_string_literal: true

require 'apeye/definitions/argument'

module APeye
  module DSLs
    class ArgumentSet
      def initialize(argument_set)
        @argument_set = argument_set
      end

      def argument_set_name(name)
        @argument_set.name = name
      end

      def description(value)
        @argument_set.description = value
      end

      def argument(name, type: nil, **options, &block)
        if type.nil?
          raise ManifestError, "Field #{name} is missing a type"
        elsif type.is_a?(Array)
          options[:type] = type[0]
          options[:array] = true
        else
          options[:type] = type
          options[:array] = false
        end

        argument = Definitions::Argument.new(name, **options)
        argument.dsl.instance_eval(&block) if block_given?

        @argument_set.arguments[name.to_sym] = argument
      end
    end
  end
end
