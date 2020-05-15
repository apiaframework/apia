# frozen_string_literal: true

require 'rapid/dsls/polymorph'
require 'rapid/helpers'

module Rapid
  module Definitions
    class Polymorph

      attr_accessor :id
      attr_accessor :name
      attr_accessor :description
      attr_reader :options

      def initialize(id)
        @id = id
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
