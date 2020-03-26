# frozen_string_literal: true

require 'apeye/errors/manifest_error'

module APeye
  class InvalidEnumOptionError < ManifestError
    attr_reader :enum
    attr_reader :given_value
    def initialize(enum, given_value)
      @enum = enum
      @given_value = given_value
    end

    def to_s
      "Invalid option for `#{enum.class.definition.name || 'AnonymousEnum'}` (got: #{@given_value.inspect} (#{@given_value.class}))"
    end
  end
end
