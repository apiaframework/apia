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
      @source = self.class.definition.arguments.each_with_object({}) do |(arg_key, argument), source|
        given_value = hash[arg_key.to_s] || hash[arg_key.to_sym] || value_from_route(argument, request) || argument.default

        next if given_value.nil? && !argument.required?

        if given_value.nil?
          raise MissingArgumentError.new(argument, path: @path + [argument])
        end

        given_value = parse_value(argument, given_value)
        validation_errors = argument.validate_value(given_value)
        unless validation_errors.empty?
          raise InvalidArgumentError.new(argument, issue: :validation_errors, errors: validation_errors, path: @path + [argument])
        end

        source[argument.name.to_sym] = given_value
      end
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

    # Return the source object
    #
    # @return [Hash]
    def to_hash
      @source.transform_values do |value|
        value.is_a?(ArgumentSet) ? value.to_hash : value
      end
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
      end
    end

    def value_from_route(argument, request)
      return if request.nil?
      return if request.route.nil?

      route_args = request.route.extract_arguments(request.fullpath)
      if argument.type.argument_set?
        # If the argument is an argument set, we'll just want to try and
        # populate the first argument.
        if first_arg = argument.type.klass.definition.arguments.keys.first
          { first_arg.to_s => route_args[argument.name.to_s] }
        else
          {}
        end
      else
        route_args[argument.name.to_s]
      end
    end

  end
end
