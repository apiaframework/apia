# frozen_string_literal: true

require 'moonstone/defineable'

module Moonstone
  class Scalar
    attr_reader :value

    def initialize(value)
      @value = value
    end

    def cast; end

    def valid?
      false
    end

    def self.parse(value)
      new(value)
    end

    def self.id
      Defineable.class_name_to_aid(name)
    end
  end
end
