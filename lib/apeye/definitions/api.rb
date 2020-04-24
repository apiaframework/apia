# frozen_string_literal: true

require 'apeye/dsls/api'

module APeye
  module Definitions
    class API
      attr_accessor :name
      attr_reader :authenticators
      attr_reader :controllers

      def initialize(name)
        @name = name
        @authenticators = []
        @controllers = {}
      end

      def dsl
        @dsl ||= DSLs::API.new(self)
      end

      def objects
        set = Set.new([self])
        @authenticators.each { |a| set |= a.definition.objects }
        @controllers.each { |a| set |= a.controller.objects }
        set
      end
    end
  end
end
