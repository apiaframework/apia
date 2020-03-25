# frozen_string_literal: true

require 'apeye/defineable'
require 'apeye/definitions/enum'
require 'apeye/errors/invalid_enum_option_error'

module APeye
  class Enum
    extend Defineable
    set_definition_class Definitions::Enum

    def initialize(value)
      @value = value
    end

    def cast
      casted = @value
      if self.class.definition.cast
        casted = self.class.definition.cast.call(casted)
      end

      if self.class.definition.values[casted].nil?
        raise InvalidEnumOptionError.new(self, casted)
      end

      casted
    end
  end
end
