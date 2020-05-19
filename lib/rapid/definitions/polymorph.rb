# frozen_string_literal: true

require 'rapid/definition'
require 'rapid/dsls/polymorph'
require 'rapid/helpers'

module Rapid
  module Definitions
    class Polymorph < Definition

      attr_reader :options

      def setup
        @options = {}
      end

      def dsl
        @dsl ||= DSLs::Polymorph.new(self)
      end

      def validate(errors)
        @options.each_value do |option|
          option.validate(errors)
        end
      end

    end
  end
end
