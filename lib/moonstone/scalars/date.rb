# frozen_string_literal: true

require 'date'
require 'moonstone/scalar'
require 'moonstone/errors/parse_error'

module Moonstone
  module Scalars
    class Date < Moonstone::Scalar
      def valid?
        @value.is_a?(::Date)
      end

      def cast
        @value.strftime('%Y-%m-%d')
      end

      def self.parse(string)
        return new(string) if string.is_a?(::Date)

        string = string.to_s
        unless string =~ /\A\d{4}\-\d{2}\-\d{2}\z/
          raise Moonstone::ParseError, 'Date must be in the format of yyyy-mm-dd'
        end

        date = ::Date.parse(string)
        new(date)
      rescue ::ArgumentError => e
        if e.message =~ /invalid date/
          raise Moonstone::ParseError, 'Invalid date was entered'
        end

        raise
      end
    end
  end
end
