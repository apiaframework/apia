# frozen_string_literal: true

require 'apia/errors/runtime_error'

module Apia
  # This is raised when an argument set cannot be created because an argument
  # that was required is not present on the source object.
  class MissingArgumentError < Apia::RuntimeError

    attr_reader :argument

    def initialize(argument, path: [])
      @argument = argument
      @path = path
    end

    def http_status
      400
    end

    def path_string
      @path.map(&:name).join('.')
    end

    def hash
      {
        code: 'missing_required_argument',
        description: "The '#{path_string}' argument is required but has not been provided",
        detail: {
          path: @path.map(&:name),
          argument: {
            name: argument.name,
            description: argument.description
          }
        }
      }
    end

  end
end
