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
    end
  end
end
