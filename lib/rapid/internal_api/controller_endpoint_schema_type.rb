# frozen_string_literal: true

require 'rapid/object'
require 'rapid/internal_api/endpoint_schema_type'

module Rapid
  module InternalAPI
    class ControllerEndpointSchemaType < Rapid::Object

      field :name, type: :string
      field :endpoint, type: EndpointSchemaType

    end
  end
end
