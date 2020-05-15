# frozen_string_literal: true

require 'rapid/dsls/object'
require 'rapid/field_set'

module Rapid
  module Definitions
    class Object

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
        @dsl ||= DSLs::Object.new(self)
      end

      def validate(errors)
        @fields.validate(errors, self)
      end

    end
  end
end
