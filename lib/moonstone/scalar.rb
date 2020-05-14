# frozen_string_literal: true

require 'moonstone/helpers'
require 'moonstone/definitions/scalar'
require 'moonstone/defineable'

module Moonstone
  class Scalar

    extend Defineable

    # Return the definition for this type
    #
    # @return [Moonstone::Definitions::Type]
    def self.definition
      @definition ||= Definitions::Scalar.new(Helpers.class_name_to_id(name))
    end

    def self.cast(value = nil, &block)
      if block_given? && value.nil?
        return definition.dsl.cast(&block)
      end

      return value if definition.cast.nil?

      definition.cast.call(value)
    end

    def self.valid?(value)
      return true if definition.validator.nil?

      definition.validator.call(value)
    end

    def self.parse(value = nil, &block)
      if block_given? && value.nil?
        return definition.dsl.parse(&block)
      end

      return value if definition.parse.nil?

      definition.parse.call(value)
    end

  end
end
