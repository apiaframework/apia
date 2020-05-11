# frozen_string_literal: true

require 'apeye/defineable'
require 'apeye/definitions/argument_set'
require 'apeye/errors/missing_argument_error'
require 'apeye/errors/invalid_argument_error'

module APeye
  class ArgumentSet
    extend Defineable

    def self.definition
      @definition ||= Definitions::ArgumentSet.new(name&.split('::')&.last)
    end

    def self.collate_objects(set)
      definition.arguments.values.each do |argument|
        set.add_object(argument.type)
      end
    end

    def self.create_from_request(request)
      new(request.json_body || request.params || {})
    end

    def inspect
      "<#{self.class.definition.name} #{@source.inspect}>"
    end

    def initialize(hash, path: [])
      unless hash.is_a?(Hash)
        raise APeye::RuntimeError, 'Hash was expected for argument'
      end

      @path = path
      @source = hash.each_with_object({}) do |(key, value), source|
        argument = self.class.definition.arguments[key.to_sym]
        next unless argument

        value = parse_value(argument, value)
        validation_errors = argument.validate_value(value)
        unless validation_errors.empty?
          raise InvalidArgumentError.new(
            argument,
            value,
            issue: :validation_errors,
            validation_errors: validation_errors,
            path: @path + [argument]
          )
        end

        source[key.to_sym] = value
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
        value.each_with_index.map do |v, index|
          parse_value(argument, v, index: index)
        end

      elsif argument.type.ancestors.include?(APeye::Scalar)
        type = argument.type.new(value)
        unless type.valid?
          raise InvalidArgumentError.new(
            argument,
            type,
            issue: :invalid_scalar_type,
            index: index,
            path: @path + [argument]
          )
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

        raise MissingArgumentError.new(arg, path: @path + [arg])
      end
    end
  end
end
