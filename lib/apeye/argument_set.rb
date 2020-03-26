# frozen_string_literal: true

require 'apeye/defineable'
require 'apeye/definitions/argument_set'
require 'apeye/errors/missing_argument_error'
require 'apeye/errors/invalid_argument_error'

module APeye
  class ArgumentSet
    extend Defineable

    def self.definition
      @definition ||= Definitions::ArgumentSet.new
    end

    def initialize(hash, path: [])
      @path = path
      @source = hash.each_with_object({}) do |(key, value), source|
        argument = self.class.definition.arguments[key.to_sym]
        next unless argument

        source[key.to_sym] = parse_value(argument, value)
      end
      check_for_missing_required_arguments
    end

    def [](value)
      @source[value.to_sym]
    end

    def dig(*values)
      @source.dig(*values)
    end

    private

    def parse_value(argument, value, index: nil)
      if argument.array? && value.is_a?(Array)
        value.each_with_index.map { |v, index| parse_value(argument, v, index: index) }

      elsif argument.type.ancestors.include?(APeye::Scalar)
        type = argument.type.new(value)
        unless type.valid?
          raise InvalidArgumentError.new(argument, type, index: index, path: @path + [argument])
        end

        type.cast

      elsif argument.type.ancestors.include?(APeye::ArgumentSet)
        argument.type.new(value, path: @path + [argument])
      end
    end

    def check_for_missing_required_arguments
      self.class.definition.arguments.values.each do |arg|
        next unless arg.required?
        next if self[arg.name]

        raise MissingArgumentError, arg
      end
    end
  end
end
