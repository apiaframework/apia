# frozen_string_literal: true

require 'rapid/dsl'
require 'rapid/definitions/field'
require 'rapid/dsls/concerns/has_fields'

module Rapid
  module DSLs
    class Object < DSL

      include DSLs::Concerns::HasFields

      def condition(&block)
        @definition.conditions << block
      end

    end
  end
end
