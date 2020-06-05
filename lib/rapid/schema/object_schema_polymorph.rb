# frozen_string_literal: true

require 'rapid/polymorph'
require 'rapid/schema/object_schema_type'
require 'rapid/schema/scalar_schema_type'
require 'rapid/schema/enum_schema_type'
require 'rapid/schema/polymorph_schema_type'
require 'rapid/schema/api_schema_type'
require 'rapid/schema/lookup_argument_set_schema_type'

module Rapid
  module Schema
    class ObjectSchemaPolymorph < Rapid::Polymorph

      no_schema

      option :object, type: ObjectSchemaType, matcher: proc { |o| o.is_a?(Rapid::Definitions::Object) }
      option :scalar, type: ScalarSchemaType, matcher: proc { |o| o.is_a?(Rapid::Definitions::Scalar) }
      option :enum, type: EnumSchemaType, matcher: proc { |o| o.is_a?(Rapid::Definitions::Enum) }
      option :polymorph, type: PolymorphSchemaType, matcher: proc { |o| o.is_a?(Rapid::Definitions::Polymorph) }
      option :authenticator, type: AuthenticatorSchemaType, matcher: proc { |o| o.is_a?(Rapid::Definitions::Authenticator) }
      option :controller, type: ControllerSchemaType, matcher: proc { |o| o.is_a?(Rapid::Definitions::Controller) }
      option :endpoint, type: EndpointSchemaType, matcher: proc { |o| o.is_a?(Rapid::Definitions::Endpoint) }
      option :error, type: ErrorSchemaType, matcher: proc { |o| o.is_a?(Rapid::Definitions::Error) }
      option :lookup_argument_set, type: LookupArgumentSetSchemaType, matcher: proc { |o| o.is_a?(Rapid::Definitions::LookupArgumentSet) }
      option :argument_set, type: ArgumentSetSchemaType, matcher: proc { |o| o.is_a?(Rapid::Definitions::ArgumentSet) }
      option :api, type: APISchemaType, matcher: proc { |o| o.is_a?(Rapid::Definitions::API) }

    end
  end
end
