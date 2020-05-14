# frozen_string_literal: true

require 'moonstone/errors/runtime_error'

module Moonstone
  class InvalidScalarValueError < Moonstone::RuntimeError

    attr_reader :scalar
    attr_reader :given_value

    def initialize(scalar, given_value)
      @scalar = scalar
      @given_value = given_value
    end

    def to_s
      "Invalid value for `#{scalar.name}` (got: #{@given_value.inspect} (#{@given_value.class}))"
    end

  end
end
