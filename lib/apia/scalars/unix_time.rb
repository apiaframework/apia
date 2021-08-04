# frozen_string_literal: true

require 'time'
require 'apia/scalars'
require 'apia/scalar'
require 'apia/errors/parse_error'

module Apia
  module Scalars
    class UnixTime < Apia::Scalar

      Scalars.register :unix_time, self

      name 'Unix Timestamp'

      cast do |time|
        time.to_i
      end

      validator do |value|
        value.is_a?(::Time)
      end

      parse do |integer|
        next integer if integer.is_a?(::Time)

        unless integer.is_a?(::Integer)
          raise Apia::ParseError, 'Time must be provided as an integer'
        end

        if integer.negative?
          raise Apia::ParseError, 'Integer must be positive or zero'
        end

        Time.at(integer).utc
      end

    end
  end
end
