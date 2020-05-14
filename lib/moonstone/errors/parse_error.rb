# frozen_string_literal: true

require 'moonstone/errors/runtime_error'

module Moonstone
  # A parse error is raised when we are unable to parse input provided by an
  # API consumer to turn it into an appropriate Scalar or Type.
  class ParseError < Moonstone::RuntimeError
  end
end
