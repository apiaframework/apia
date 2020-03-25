# frozen_string_literal: true

module APeye
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
  end
end
