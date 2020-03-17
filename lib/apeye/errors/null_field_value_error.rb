# frozen_string_literal: true

require 'apeye/errors/parse_error'
module APeye
  class NullFieldValueError < ParseError
    attr_reader :field
    def initialize(field)
      @field = field
    end

    def to_s
      "Value for `#{field.name}` is null (but cannot be)"
    end
  end
end
