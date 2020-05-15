# frozen_string_literal: true

require 'rapid/polymorph'
require 'rapid/internal_api/object_schema_type'
require 'rapid/internal_api/scalar_schema_type'
require 'rapid/internal_api/enum_schema_type'
require 'rapid/internal_api/polymorph_schema_type'

module Rapid
  module InternalAPI
    class TypeSchemaPolymorph < Rapid::Polymorph

      option :object, type: ObjectSchemaType, matcher: proc { |o| o.is_a?(Rapid::Definitions::Object) }
      option :scalar, type: ScalarSchemaType, matcher: proc { |o| o.is_a?(Rapid::Definitions::Scalar) }
      option :enum, type: EnumSchemaType, matcher: proc { |o| o.is_a?(Rapid::Definitions::Enum) }
      option :polymorph, type: PolymorphSchemaType, matcher: proc { |o| o.is_a?(Rapid::Definitions::Polymorph) }

    end
  end
end
