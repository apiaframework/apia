# frozen_string_literal: true

require 'apeye/defineable'
require 'apeye/definitions/argument_set'

module APeye
  class ArgumentSet
    extend Defineable

    def self.definition
      @definition ||= Definitions::ArgumentSet.new
    end

    def initialize(value)
      @value = value
    end
  end
end
