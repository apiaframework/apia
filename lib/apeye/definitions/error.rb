# frozen_string_literal: true

require 'apeye/dsls/error'
require 'apeye/definitions/concerns/has_fields'

module APeye
  module Definitions
    class Error
      include APeye::Definitions::Concerns::HasFields

      attr_accessor :name
      attr_accessor :code
      attr_accessor :http_status
      attr_accessor :description

      def initialize(name)
        @name = name
      end

      def dsl
        @dsl ||= DSLs::Error.new(self)
      end
    end
  end
end
