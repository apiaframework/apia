# frozen_string_literal: true

require 'apeye/scalars/string'
require 'apeye/scalars/integer'
require 'apeye/scalars/boolean'
require 'apeye/scalars/date'

module APeye
  module Scalars
    ALL = {
      string: Scalars::String,
      integer: Scalars::Integer,
      boolean: Scalars::Boolean,
      date: Scalars::Date
    }.freeze
  end
end
