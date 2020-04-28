# frozen_string_literal: true

require 'apeye/dsls/api'

module APeye
  module Definitions
    class API
      attr_accessor :name
      attr_accessor :authenticator
      attr_reader :controllers

      def initialize(name)
        @name = name
        @controllers = {}
      end

      def dsl
        @dsl ||= DSLs::API.new(self)
      end

      def validate(errors); end
    end
  end
end
