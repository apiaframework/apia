# frozen_string_literal: true

require 'apia/errors/runtime_error'

module Apia
  # A parse error is raised when we are unable to parse input provided by an
  # API consumer to turn it into an appropriate Scalar or Type.
  class ParseError < Apia::RuntimeError
  end
end
