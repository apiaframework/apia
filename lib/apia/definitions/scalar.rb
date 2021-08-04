# frozen_string_literal: true

require 'apia/definition'
require 'apia/dsls/scalar'

module Apia
  module Definitions
    class Scalar < Definition

      attr_accessor :cast
      attr_accessor :parse
      attr_accessor :validator

      def dsl
        @dsl ||= DSLs::Scalar.new(self)
      end

      def validate(errors)
      end

    end
  end
end
