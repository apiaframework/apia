# frozen_string_literal: true

require 'apia/definition'
require 'apia/dsls/object'
require 'apia/field_set'

module Apia
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
