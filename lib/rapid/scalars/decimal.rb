# frozen_string_literal: true

require 'rapid/scalars'
require 'rapid/scalar'

module Rapid
  module Scalars
    class Decimal < Rapid::Scalar

      Scalars.register :decimal, self

      name 'Decimal'

      cast do |value|
        value.to_f
      end

      validator do |value|
        value.is_a?(::Float)
      end

      parse do |value|
        if value.is_a?(::String) && value =~ /\A\-?\d+(\.\d+)?\z/
          value.to_f
        elsif value.is_a?(::Float)
          value
        elsif value.is_a?(::Integer)
          value.to_i
        else
          raise Rapid::ParseError, 'Decimal must be provided as a decimal, integer or a string only containing numbers'
        end
      end

    end
  end
end
