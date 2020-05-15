# frozen_string_literal: true

require 'rapid/errors/runtime_error'

module Rapid
  # A parse error is raised when we are unable to parse input provided by an
  # API consumer to turn it into an appropriate Scalar or Type.
  class ParseError < Rapid::RuntimeError
  end
end
