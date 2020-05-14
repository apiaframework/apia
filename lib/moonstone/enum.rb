# frozen_string_literal: true

require 'moonstone/helpers'
require 'moonstone/defineable'
require 'moonstone/definitions/enum'
require 'moonstone/errors/invalid_enum_option_error'

module Moonstone
  class Enum

    extend Defineable

    def self.definition
      @definition ||= Definitions::Enum.new(Helpers.class_name_to_id(name))
    end

    def self.cast(value = nil, &block)
      if block_given? && value.nil?
        return definition.dsl.cast(&block)
      end

      value = definition.cast.call(value) if definition.cast

      if definition.values[value].nil?
        raise InvalidEnumOptionError.new(self, value)
      end

      value
    end

  end
end
