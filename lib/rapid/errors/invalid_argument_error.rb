# frozen_string_literal: true

require 'rapid/errors/runtime_error'

module Rapid
  # Raised when an argument set cannot be created based on the source object that
  # has been provided. For example, if a validation rule exists or a scalar cannot
  # be parsed for the underlying object.
  #
  # This is not raised for MISSING argument errors.
  class InvalidArgumentError < Rapid::RuntimeError

    ISSUE_DESCRIPTIONS = {
      invalid_scalar: 'The value provided was not of an appropriate type for the scalar that was requested. For example, you may have passed a string where an integer was required etc...',
      parse_error: 'The value provided could not be parsed into an appropriate value by the server. For example, if a date was expected and the value could not be interpretted as such.',
      validation_error: 'A validation rule that has been specified for this argument was not satisfied. See the further details in the response and in the documentation.',
      invalid_enum_value: 'The value provided was not one of the options suitable for the enum.'
    }.freeze

    attr_reader :argument
    attr_reader :index
    attr_reader :path
    attr_reader :errors
    attr_reader :issue

    def initialize(argument, issue: nil, index: nil, path: [], errors: [])
      @argument = argument
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
          issue_description: ISSUE_DESCRIPTIONS[@issue.to_sym],
          errors: @errors,
          argument: {
            id: argument.id,
            name: argument.name,
            description: argument.description
          }
        }
      }
    end

  end
end
