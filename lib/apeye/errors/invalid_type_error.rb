# frozen_string_literal: true

require 'apeye/errors/manifest_error'

module APeye
  class InvalidTypeError < ManifestError
    attr_reader :field
    attr_reader :given_value
    def initialize(field, given_value)
      @field = field
      @given_value = given_value
    end

    def to_s
      "Invalid type for `#{field.name}` (got: #{@given_value.inspect} (#{@given_value.class}))"
    end
  end
end
