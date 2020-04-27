# frozen_string_literal: true

require 'apeye/errors/runtime_error'

module APeye
  # This is raised when an argument set cannot be created because an argument
  # that was required is not present on the source object.
  class MissingArgumentError < APeye::RuntimeError
    attr_reader :argument
    def initialize(argument)
      @argument = argument
    end
  end
end
