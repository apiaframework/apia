# frozen_string_literal: true

require 'apia/errors/runtime_error'

module Apia
  class FieldSpecParseError < Apia::RuntimeError

    def http_status
      400
    end

    def hash
      {
        code: 'invalid_field_spec',
        description: 'The field spec string was invalid',
        detail: {
          details: message
        }
      }
    end

  end
end
