# frozen_string_literal: true

require 'moonstone/scalars/string'
require 'moonstone/scalars/integer'
require 'moonstone/scalars/boolean'
require 'moonstone/scalars/date'

module Moonstone
  module Scalars

    ALL = {
      string: Scalars::String,
      integer: Scalars::Integer,
      boolean: Scalars::Boolean,
      date: Scalars::Date
    }.freeze

  end
end
