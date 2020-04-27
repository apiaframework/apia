# frozen_string_literal: true

require 'apeye/dsls/authenticator'

module APeye
  module Definitions
    class Authenticator
      TYPES = [:bearer].freeze

      attr_accessor :name
      attr_accessor :type
      attr_accessor :action
      attr_reader :potential_errors

      def initialize(name)
        @name = name
        @potential_errors = []
      end

      def dsl
        @dsl ||= DSLs::Authenticator.new(self)
      end
    end
  end
end
