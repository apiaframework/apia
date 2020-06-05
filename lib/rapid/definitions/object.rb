# frozen_string_literal: true

require 'rapid/definition'
require 'rapid/dsls/object'
require 'rapid/field_set'

module Rapid
  module Definitions
    class Object < Definition

      attr_reader :conditions
      attr_reader :fields

      def setup
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
