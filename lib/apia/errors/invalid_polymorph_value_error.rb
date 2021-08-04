# frozen_string_literal: true

require 'apia/errors/runtime_error'

module Apia
  class InvalidPolymorphValueError < Apia::RuntimeError

    attr_reader :polymorph
    attr_reader :given_value

    def initialize(polymorph, given_value)
      @polymorph = polymorph
      @given_value = given_value
    end

    def to_s
      "Invalid value for `#{polymorph.definition.id}` (got: #{@given_value.inspect})"
    end

  end
end
