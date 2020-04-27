# frozen_string_literal: true

require 'apeye/definitions/field'
require 'apeye/dsls/concerns/has_fields'

module APeye
  module DSLs
    class Type
      include DSLs::Concerns::HasFields

      def initialize(definition)
        @definition = definition
      end

      def name_override(value)
        @definition.name = value
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
