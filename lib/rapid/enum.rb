# frozen_string_literal: true

require 'rapid/helpers'
require 'rapid/defineable'
require 'rapid/definitions/enum'
require 'rapid/errors/invalid_enum_option_error'

module Rapid
  class Enum

    extend Defineable

    class << self

      # Return the definition object for the enum
      #
      # @return [Rapid::Definitions::Enum]
      def definition
        @definition ||= Definitions::Enum.new(Helpers.class_name_to_id(name))
      end

      # Cast a value or define a new block for casting (for DSL purposes)
      #
      # @param value [Object?]
      # @return [Object?]
      def cast(value = nil, &block)
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
end
