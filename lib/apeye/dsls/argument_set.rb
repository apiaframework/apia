# frozen_string_literal: true

require 'apeye/definitions/argument'

module APeye
  module DSLs
    class ArgumentSet
      def initialize(definition)
        @definition = definition
      end

      def name_override(name)
        @definition.name = name
      end

      def description(value)
        @definition.description = value
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

        @definition.arguments[name.to_sym] = argument
      end
    end
  end
end
