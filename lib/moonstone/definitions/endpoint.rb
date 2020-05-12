# frozen_string_literal: true

require 'moonstone/dsls/endpoint'
require 'moonstone/definitions/concerns/has_fields'

module Moonstone
  module Definitions
    class Endpoint
      include Definitions::Concerns::HasFields

      attr_accessor :name
      attr_accessor :label
      attr_accessor :description
      attr_accessor :authenticator
      attr_accessor :action
      attr_reader :argument_set
      attr_reader :potential_errors

      def initialize(name)
        @name = name
        @potential_errors = []
        @fields = {}
        @argument_set = Moonstone::ArgumentSet.create('BaseEndpointArgumentSet')
      end

      def dsl
        @dsl ||= DSLs::Endpoint.new(self)
      end

      def validate(errors); end
    end
  end
end
