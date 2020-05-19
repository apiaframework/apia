# frozen_string_literal: true

require 'rapid/definition'
require 'rapid/dsls/enum'

module Rapid
  module Definitions
    class Enum < Definition

      attr_accessor :cast
      attr_reader :values

      def setup
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
