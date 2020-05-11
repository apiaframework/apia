# frozen_string_literal: true

require 'apeye/errors/runtime_error'

module APeye
  class InvalidJSONError < RuntimeError
    def http_status
      400
    end

    def hash
      {
        code: 'invalid_json_body',
        message: 'The JSON body provided with this request is invalid',
        detail: {
          details: message
        }
      }
    end
  end
end
