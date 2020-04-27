# frozen_string_literal: true

require 'apeye/errors/runtime_error'

module APeye
  class NullFieldValueError < RuntimeError
    attr_reader :field
    def initialize(field)
      @field = field
    end

    def to_s
      "Value for `#{field.name}` is null (but cannot be)"
    end
  end
end
