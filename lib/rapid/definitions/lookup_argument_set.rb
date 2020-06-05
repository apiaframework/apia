# frozen_string_literal: true

require 'rapid/definitions/argument_set'
require 'rapid/dsls/lookup_argument_set'

module Rapid
  module Definitions
    class LookupArgumentSet < Definitions::ArgumentSet

      attr_accessor :resolver

      def dsl
        @dsl ||= DSLs::LookupArgumentSet.new(self)
      end

      def potential_errors
        @potential_errors ||= ErrorSet.new
      end

      def validate(errors)
        super
        @potential_errors&.validate(errors, self)
      end

    end
  end
end
