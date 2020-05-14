# frozen_string_literal: true

require 'moonstone/errors/runtime_error'

module Moonstone
  class NullFieldValueError < Moonstone::RuntimeError

    attr_reader :field

    def initialize(field)
      @field = field
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
            name: @field.name
          }
        }
      }
    end

  end
end
