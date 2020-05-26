# frozen_string_literal: true

require 'rapid/defineable'
require 'rapid/definitions/argument_set'
require 'rapid/errors/invalid_argument_error'
require 'rapid/errors/missing_argument_error'
require 'rapid/helpers'

module Rapid
  class ArgumentSet

    extend Defineable

    class << self

      # Return the definition for this argument set
      #
      # @return [Rapid::Definitions::ArgumentSet]
      def definition
        @definition ||= Definitions::ArgumentSet.new(Helpers.class_name_to_id(name))
      end

      # Finds all objects referenced by this argument set and add them
      # to the provided set.
      #
      # @param set [Rapid::ObjectSet]
      # @return [void]
      def collate_objects(set)
        definition.arguments.each_value do |argument|
          set.add_object(argument.type.klass) if argument.type.usable_for_argument?
        end
      end

      # Create a new argument set from a request object
      #
      # @param request [Rapid::Request]
      # @return [Rapid::ArgumentSet]
      def create_from_request(request)
        new(request.json_body || request.params || {}, request: request)
      end

    end

    # Create a new argument set by providing a hash containing the raw
    # arguments
    #
    # @param hash [Hash]
    # @param path [Array]
    # @return [Rapid::ArgumentSet]
    def initialize(hash, path: [], request: nil)
      unless hash.is_a?(Hash)
        raise Rapid::RuntimeError, 'Hash was expected for argument'
      end

      @path = path
      @request = request
      @source = hash.each_with_object({}) do |(key, value), source|
        argument = self.class.definition.arguments[key.to_sym]
        next unless argument

        value = parse_value(argument, value)
        validation_errors = argument.validate_value(value)
        unless validation_errors.empty?
          raise InvalidArgumentError.new(argument, issue: :validation_errors, errors: validation_errors, path: @path + [argument])
        end

        source[key.to_sym] = value
      end
      check_for_missing_required_arguments
    end

    # Return an item from the argument set
    #
    # @param value [String, Symbol]
    # @return [Object, nil]
    def [](value)
      @source[value.to_sym]
    end

    # Return an item from this argument set
    #
    # @param values [Array<String, Symbol>]
    # @return [Object, nil]
    def dig(*values)
      @source.dig(*values)
    end

    # Validate an argument set and return any errors as appropriate
    #
    # @param argument [Rapid::Argument]
    def validate(argument, index: nil)
    end

    private

    def parse_value(argument, value, index: nil, in_array: false)
      if argument.array? && value.is_a?(Array)
        value.each_with_index.map do |v, i|
          parse_value(argument, v, index: i, in_array: true)
        end

      elsif argument.array? && !in_array
        raise InvalidArgumentError.new(argument, issue: :array_expected, index: index, path: @path + [argument])

      elsif argument.type.scalar?
        begin
          type = argument.type.klass.parse(value)
        rescue Rapid::ParseError => e
          # If we cannot parse the given input, this is cause for a parse error to be raised.
          raise InvalidArgumentError.new(argument, issue: :parse_error, errors: [e.message], index: index, path: @path + [argument])
        end

        unless argument.type.klass.valid?(type)
          # If value we have parsed is not actually valid, we 'll raise an argument error.
          # In most cases, it is likely that an integer has been provided to string etc...
          raise InvalidArgumentError.new(argument, issue: :invalid_scalar, index: index, path: @path + [argument])
        end

        type

      elsif argument.type.argument_set?
        unless value.is_a?(Hash)
          raise InvalidArgumentError.new(argument, issue: :object_expected, index: index, path: @path + [argument])
        end

        value = argument.type.klass.new(value, path: @path + [argument], request: @request)
        value.validate(argument, index: index)
        value

      elsif argument.type.enum?
        unless argument.type.klass.definition.values[value]
          raise InvalidArgumentError.new(argument, issue: :invalid_enum_value, index: index, path: @path + [argument])
        end

        value
      end
    end

    def check_for_missing_required_arguments
      self.class.definition.arguments.each_value do |arg|
        next unless arg.required?
        next if self[arg.name]

        raise MissingArgumentError.new(arg, path: @path + [arg])
      end
    end

  end
end
