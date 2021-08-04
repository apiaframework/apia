# frozen_string_literal: true

require 'apia/polymorph'
require 'apia/schema/object_schema_type'
require 'apia/schema/scalar_schema_type'
require 'apia/schema/enum_schema_type'
require 'apia/schema/polymorph_schema_type'
require 'apia/schema/api_schema_type'
require 'apia/schema/lookup_argument_set_schema_type'

module Apia
  module Schema
    class ObjectSchemaPolymorph < Apia::Polymorph

      no_schema

      option :object, type: ObjectSchemaType, matcher: proc { |o| o.is_a?(Apia::Definitions::Object) }
      option :scalar, type: ScalarSchemaType, matcher: proc { |o| o.is_a?(Apia::Definitions::Scalar) }
      option :enum, type: EnumSchemaType, matcher: proc { |o| o.is_a?(Apia::Definitions::Enum) }
      option :polymorph, type: PolymorphSchemaType, matcher: proc { |o| o.is_a?(Apia::Definitions::Polymorph) }
      option :authenticator, type: AuthenticatorSchemaType, matcher: proc { |o| o.is_a?(Apia::Definitions::Authenticator) }
      option :controller, type: ControllerSchemaType, matcher: proc { |o| o.is_a?(Apia::Definitions::Controller) }
      option :endpoint, type: EndpointSchemaType, matcher: proc { |o| o.is_a?(Apia::Definitions::Endpoint) }
      option :error, type: ErrorSchemaType, matcher: proc { |o| o.is_a?(Apia::Definitions::Error) }
      option :lookup_argument_set, type: LookupArgumentSetSchemaType, matcher: proc { |o| o.is_a?(Apia::Definitions::LookupArgumentSet) }
      option :argument_set, type: ArgumentSetSchemaType, matcher: proc { |o| o.is_a?(Apia::Definitions::ArgumentSet) }
      option :api, type: APISchemaType, matcher: proc { |o| o.is_a?(Apia::Definitions::API) }

    end
  end
end
