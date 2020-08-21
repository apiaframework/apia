# frozen_string_literal: true

require 'rapid/scalars'
require 'rapid/scalar'

module Rapid
  module Scalars
    class Integer < Rapid::Scalar

      Scalars.register :integer, self

      name 'Integer'

      cast do |value|
        value.to_i
      end

      validator do |value|
        value.is_a?(::Integer)
      end

      parse do |value|
        if value.is_a?(::String) && value =~ /\A-?\d+\z/
          value.to_i
        elsif value.is_a?(::Integer)
          value
        else
          raise Rapid::ParseError, 'Integer must be provided as an integer or a string only containing numbers'
        end
      end

    end
  end
end
