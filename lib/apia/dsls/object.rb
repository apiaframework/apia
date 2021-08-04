# frozen_string_literal: true

require 'apia/dsl'
require 'apia/definitions/field'
require 'apia/dsls/concerns/has_fields'

module Apia
  module DSLs
    class Object < DSL

      include DSLs::Concerns::HasFields

      def condition(&block)
        @definition.conditions << block
      end

    end
  end
end
