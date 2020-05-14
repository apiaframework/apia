# frozen_string_literal: true

require 'moonstone/dsls/enum'

module Moonstone
  module Definitions
    class Enum

      attr_accessor :id
      attr_accessor :name
      attr_accessor :description
      attr_accessor :cast
      attr_reader :values

      def initialize(id)
        @id = id
        @values = {}
      end

      def dsl
        @dsl ||= DSLs::Enum.new(self)
      end

      def validate(errors)
        if cast && !cast.is_a?(Proc)
          errors.add self, 'CastMustBeProc', 'The value provided for casting an enum must be an instance of Proc'
        end
      end

    end
  end
end
