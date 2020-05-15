# frozen_string_literal: true

require 'rapid/definitions/field'
require 'rapid/dsls/concerns/has_fields'

module Rapid
  module DSLs
    class Object

      include DSLs::Concerns::HasFields

      def initialize(definition)
        @definition = definition
      end

      def name(name)
        @definition.name = name
      end

      def description(value)
        @definition.description = value
      end

      def condition(&block)
        @definition.conditions << block
      end

    end
  end
end
