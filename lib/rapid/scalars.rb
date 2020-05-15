# frozen_string_literal: true

require 'rapid/scalars/string'
require 'rapid/scalars/integer'
require 'rapid/scalars/boolean'
require 'rapid/scalars/date'

module Rapid
  module Scalars

    ALL = {
      string: Scalars::String,
      integer: Scalars::Integer,
      boolean: Scalars::Boolean,
      date: Scalars::Date
    }.freeze

  end
end
