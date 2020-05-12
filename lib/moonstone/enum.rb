# frozen_string_literal: true

require 'moonstone/defineable'
require 'moonstone/definitions/enum'
require 'moonstone/errors/invalid_enum_option_error'

module Moonstone
  class Enum
    extend Defineable

    def self.definition
      @definition ||= Definitions::Enum.new(name&.split('::')&.last)
    end

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
