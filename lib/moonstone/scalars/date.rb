# frozen_string_literal: true

require 'date'
require 'moonstone/scalar'
require 'moonstone/errors/parse_error'

module Moonstone
  module Scalars
    class Date < Moonstone::Scalar

      cast do |value|
        value.strftime('%Y-%m-%d')
      end

      validator do |value|
        value.is_a?(::Date)
      end

      parse do |string|
        next string if string.is_a?(::Date)

        begin
          string = string.to_s
          unless string =~ /\A\d{4}\-\d{2}\-\d{2}\z/
            raise Moonstone::ParseError, 'Date must be in the format of yyyy-mm-dd'
          end

          ::Date.parse(string)
        rescue ::ArgumentError => e
          if e.message =~ /invalid date/
            raise Moonstone::ParseError, 'Invalid date was entered (make sure the day exists)'
          end

          raise
        end
      end

    end
  end
end
