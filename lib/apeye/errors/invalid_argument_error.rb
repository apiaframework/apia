# frozen_string_literal: true

require 'apeye/errors/parse_error'

module APeye
  class InvalidArgumentError < APeye::ParseError
    attr_reader :argument
    attr_reader :type_instance
    attr_reader :index
    attr_reader :path
    attr_reader :validation_errors
    def initialize(argument, type_instance, index: nil, path: [], validation_errors: [])
      @argument = argument
      @type_instance = type_instance
      @index = index
      @path = path
      @validation_errors = validation_errors
    end
  end
end
