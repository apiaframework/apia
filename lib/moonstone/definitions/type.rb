# frozen_string_literal: true

require 'moonstone/dsls/type'
require 'moonstone/definitions/concerns/has_fields'

module Moonstone
  module Definitions
    class Type
      include Definitions::Concerns::HasFields

      attr_accessor :id
      attr_accessor :description
      attr_reader :conditions

      def initialize(id)
        @id = id
        @conditions = []
      end

      def dsl
        @dsl ||= DSLs::Type.new(self)
      end

      def validate(errors); end
    end
  end
end
