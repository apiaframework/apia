# frozen_string_literal: true

require 'apia/definition'
require 'apia/dsls/polymorph'
require 'apia/helpers'

module Apia
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
