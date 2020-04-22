# frozen_string_literal: true

require 'apeye/definitions/field'
require 'apeye/errors/parse_error'

module APeye
  module DSLs
    class Type
      def initialize(type_definition)
        @type_definition = type_definition
      end

      def name_override(value)
        @type_definition.name = value
      end

      def description(value)
        @type_definition.description = value
      end

      def field(name, type: nil, **options, &block)
        if type.is_a?(Array)
          options[:type] = type[0]
          options[:array] = true
        else
          options[:type] = type
          options[:array] = false
        end

        field = Definitions::Field.new(name, **options)
        field.dsl.instance_eval(&block) if block_given?

        if field.type.nil?
          raise ManifestError, "Field #{name} is missing a type"
        end

        @type_definition.fields[name.to_sym] = field
      end

      def condition(&block)
        @type_definition.conditions << block
      end
    end
  end
end
