# frozen_string_literal: true

require 'rapid/errors/runtime_error'

module Rapid
  # This is the error exception that must be raised when you wish to raise an
  # error. It should be initialized with the Rapid::Error class that you wish
  # to raise.
  class ErrorExceptionError < Rapid::RuntimeError

    attr_reader :error_class

    def initialize(error_class, fields = {})
      @error_class = error_class
      @fields = fields
    end

    def http_status
      @error_class.definition.http_status || 500
    end

    def hash
      {
        code: @error_class.definition.code,
        description: @error_class.definition.description,
        detail: @error_class.definition.fields.generate_hash(@fields)
      }
    end

  end
end
