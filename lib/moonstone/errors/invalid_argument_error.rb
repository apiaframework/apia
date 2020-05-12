# frozen_string_literal: true

require 'moonstone/errors/runtime_error'

module Moonstone
  # Raised when an argument set cannot be created based on the source object that
  # has been provided. For example, if a validation rule exists or a scalar cannot
  # be parsed for the underlying object.
  #
  # This is not raised for MISSING argument errors.
  class InvalidArgumentError < Moonstone::RuntimeError
    attr_reader :argument
    attr_reader :type_instance
    attr_reader :index
    attr_reader :path
    attr_reader :errors
    attr_reader :issue

    def initialize(argument, type_instance, issue: nil, index: nil, path: [], errors: [])
      @argument = argument
      @type_instance = type_instance
      @index = index
      @path = path
      @issue = issue
      @errors = errors
    end

    def http_status
      400
    end

    def path_string
      @path.map(&:name).join('.')
    end

    def hash
      {
        code: 'invalid_argument',
        description: "The '#{path_string}' argument is invalid",
        detail: {
          path: @path.map(&:name),
          index: @index,
          issue: @issue&.to_s,
          errors: @errors,
          argument: {
            name: argument.name,
            description: argument.description
          }
        }
      }
    end
  end
end
