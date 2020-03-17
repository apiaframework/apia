# frozen_string_literal: true

require 'apeye/types/string'
require 'apeye/types/integer'
require 'apeye/types/boolean'
require 'apeye/types/date'

module APeye
  module Types
    ALL = {
      string: Types::String,
      integer: Types::Integer,
      boolean: Types::Boolean,
      date: Types::Date
    }.freeze
  end
end
