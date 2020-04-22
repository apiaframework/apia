# frozen_string_literal: true

require 'apeye/dsls/type'

module APeye
  module Definitions
    class Type
      attr_accessor :name
      attr_accessor :description
      attr_reader :fields
      attr_reader :conditions

      def initialize(name)
        @name = name
        @fields = {}
        @conditions = []
      end

      def dsl
        @dsl ||= DSLs::Type.new(self)
      end
    end
  end
end
