# frozen_string_literal: true

require 'apeye/dsls/enum'

module APeye
  module Definitions
    class Enum
      attr_accessor :name
      attr_accessor :description
      attr_accessor :cast
      attr_reader :values

      def initialize
        @values = {}
      end

      def dsl
        @dsl ||= DSLs::Enum.new(self)
      end
    end
  end
end
