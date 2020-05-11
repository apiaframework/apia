# frozen_string_literal: true

require 'apeye/dsls/endpoint'
require 'apeye/definitions/concerns/has_fields'

module APeye
  module Definitions
    class Endpoint
      include Definitions::Concerns::HasFields

      attr_accessor :name
      attr_accessor :label
      attr_accessor :description
      attr_accessor :authenticator
      attr_accessor :endpoint
      attr_reader :argument_set
      attr_reader :potential_errors
      attr_reader :arguments

      def initialize(name)
        @name = name
        @potential_errors = []
        @arguments = {}
        @fields = {}
        @argument_set = APeye::ArgumentSet.create('BaseArgumentSet')
      end

      def dsl
        @dsl ||= DSLs::Endpoint.new(self)
      end
    end
  end
end
