# frozen_string_literal: true

require 'apeye/dsls/error'

module APeye
  module Definitions
    class Error
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
