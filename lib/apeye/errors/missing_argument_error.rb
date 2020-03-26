# frozen_string_literal: true

require 'apeye/errors/parse_error'

module APeye
  class MissingArgumentError < APeye::ParseError
    attr_reader :argument
    def initialize(argument)
      @argument = argument
    end
  end
end
