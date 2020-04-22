# frozen_string_literal: true

require 'apeye/dsls/argument_set'

module APeye
  module Definitions
    class ArgumentSet
      attr_accessor :name
      attr_accessor :description
      attr_reader :arguments

      def initialize(name)
        @name = name
        @arguments = {}
      end

      def dsl
        @dsl ||= DSLs::ArgumentSet.new(self)
      end
    end
  end
end
