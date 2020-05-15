# frozen_string_literal: true

require 'rapid/dsls/scalar'

module Rapid
  module Definitions
    class Scalar

      attr_accessor :id
      attr_accessor :name
      attr_accessor :description
      attr_accessor :cast
      attr_accessor :parse
      attr_accessor :validator

      def initialize(id)
        @id = id
      end

      def dsl
        @dsl ||= DSLs::Scalar.new(self)
      end

      def validate(errors)
      end

    end
  end
end
