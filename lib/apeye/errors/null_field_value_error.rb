# frozen_string_literal: true

require 'apeye/errors/manifest_error'

module APeye
  class NullFieldValueError < ManifestError
    attr_reader :field
    def initialize(field)
      @field = field
    end

    def to_s
      "Value for `#{field.name}` is null (but cannot be)"
    end
  end
end
