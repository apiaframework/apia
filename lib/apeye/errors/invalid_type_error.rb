# frozen_string_literal: true

require 'apeye/errors/runtime_error'

module APeye
  class InvalidTypeError < RuntimeError
    attr_reader :field
    attr_reader :given_value
    def initialize(field, given_value)
      @field = field
      @given_value = given_value
    end

    def to_s
      "Invalid type for `#{field.name}` (got: #{@given_value.inspect} (#{@given_value.class}))"
    end

    def http_status
      500
    end

    def hash
      {
        code: 'invalid_value_for_field',
        description: to_s,
        detail: {
          field: {
            name: @field.name,
            given_value: @given_value
          }
        }
      }
    end
  end
end
