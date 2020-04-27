# frozen_string_literal: true

require 'apeye/dsls/controller'

module APeye
  module Definitions
    class Controller
      attr_accessor :name
      attr_accessor :description
      attr_accessor :authenticator
      attr_reader :endpoints

      def initialize(name)
        @name = name
        @endpoints = {}
      end

      def dsl
        @dsl ||= DSLs::Controller.new(self)
      end
    end
  end
end
