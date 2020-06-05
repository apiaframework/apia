# frozen_string_literal: true

require 'rapid/errors/runtime_error'

module Rapid
  class NullFieldValueError < Rapid::RuntimeError

    attr_reader :field

    def initialize(field, source)
      @field = field
      @source = source
    end

    def to_s
      "Value for `#{field.name}` is null (but cannot be)"
    end

    def http_status
      500
    end

    def hash
      {
        code: 'null_value_for_non_null_field',
        description: to_s,
        detail: {
          field: {
            id: @field.id,
            name: @field.name
          }
        }
      }
    end

  end
end
