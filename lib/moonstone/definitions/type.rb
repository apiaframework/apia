# frozen_string_literal: true

require 'moonstone/dsls/type'
require 'moonstone/field_set'

module Moonstone
  module Definitions
    class Type

      attr_accessor :id
      attr_accessor :name
      attr_accessor :description
      attr_reader :conditions
      attr_reader :fields

      def initialize(id)
        @id = id
        @conditions = []
        @fields = FieldSet.new
      end

      def dsl
        @dsl ||= DSLs::Type.new(self)
      end

      def validate(errors)
        @fields.validate(errors, self)
      end

    end
  end
end
