# frozen_string_literal: true

require 'apia/scalars'
require 'apia/scalar'

module Apia
  module Scalars
    class Boolean < Apia::Scalar

      Scalars.register :boolean, self

      name 'Boolean'

      TRUE_VALUES = [true, 'true', 'yes', 1, '1'].freeze
      FALSE_VALUES = [false, 'false', 'no', 0, '0'].freeze

      cast do |value|
        value ? true : false
      end

      validator do |value|
        value.is_a?(TrueClass) || value.is_a?(FalseClass)
      end

      parse do |value|
        if TRUE_VALUES.include?(value)
          true
        elsif FALSE_VALUES.include?(value)
          false
        else
          raise Apia::ParseError, 'Boolean must be provided as a boolean, as a string containing true or false or as 0 or 1 as an integer.'
        end
      end

    end
  end
end
