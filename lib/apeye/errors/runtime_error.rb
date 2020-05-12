# frozen_string_literal: true

module APeye
  # Runtime errors occurr during API requests because they could not
  # be detected before an action is processed.
  class RuntimeError < StandardError
    # Return the default HTTP status code that should be returned when this
    # error is encoutered over HTTP
    #
    # @return [Integer]
    def http_status
      400
    end

    # Return the hash that describes this error
    #
    # @return [Hash]
    def hash
      {
        code: 'generic_runtime_error',
        description: message,
        detail: {
          class: self.class.name
        }
      }
    end
  end
end
