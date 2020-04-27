# frozen_string_literal: true

require 'apeye/errors/runtime_error'

module APeye
  # A parse error is raised when we are unable to parse input provided by an
  # API consumer to turn it into an appropriate Scalar or Type.
  class ParseError < RuntimeError
  end
end
