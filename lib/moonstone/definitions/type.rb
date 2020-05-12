# frozen_string_literal: true

require 'moonstone/dsls/type'
require 'moonstone/definitions/concerns/has_fields'

module Moonstone
  module Definitions
    class Type
      include Definitions::Concerns::HasFields

      attr_accessor :name
      attr_accessor :description
      attr_reader :conditions

      def initialize(name)
        @name = name
        @conditions = []
      end

      def dsl
        @dsl ||= DSLs::Type.new(self)
      end
    end
  end
end
