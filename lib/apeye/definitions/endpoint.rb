# frozen_string_literal: true

require 'apeye/dsls/endpoint'
require 'apeye/definitions/concerns/has_fields'

module APeye
  module Definitions
    class Endpoint
      include Definitions::Concerns::HasFields

      attr_reader :id
      attr_accessor :name
      attr_accessor :description
      attr_accessor :authenticator
      attr_accessor :endpoint
      attr_reader :potential_errors
      attr_reader :arguments

      def initialize(id)
        @id = id
        @potential_errors = []
        @arguments = {}
        @fields = {}
      end

      def dsl
        @dsl ||= DSLs::Endpoint.new(self)
      end
    end
  end
end
