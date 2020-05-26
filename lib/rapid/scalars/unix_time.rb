# frozen_string_literal: true

require 'time'
require 'rapid/scalars'
require 'rapid/scalar'
require 'rapid/errors/parse_error'

module Rapid
  module Scalars
    class UnixTime < Rapid::Scalar

      Scalars.register :unix_time, self

      cast do |time|
        time.to_i
      end

      validator do |value|
        value.is_a?(::Time)
      end

      parse do |integer|
        next integer if integer.is_a?(::Time)

        unless integer.is_a?(::Integer)
          raise Rapid::ParseError, 'Time must be provided as an integer'
        end

        if integer.negative?
          raise Rapid::ParseError, 'Integer must be positive or zero'
        end

        Time.at(integer)
      end

    end
  end
end
