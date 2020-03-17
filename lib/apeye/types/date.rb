# frozen_string_literal: true

require 'date'
require 'apeye/type'

module APeye
  module Types
    class Date < APeye::Type
      type_name 'Date'
      description 'A date (e.g. 2019-01-01)'

      def valid?
        @value.is_a?(::Date)
      end

      def cast
        @value.strftime('%Y-%m-%d')
      end

      def self.parse(string)
        return new(string) if string.is_a?(::Date)

        string = string.to_s
        return false unless string =~ /\A\d{4}\-\d{2}\-\d{2}\z/

        date = ::Date.parse(string)
        new(date)
      rescue ArgumentError => e
        e.message =~ /invalid date/ ? false : raise
      end
    end
  end
end
