# frozen_string_literal: true

require 'moonstone/object'
require 'moonstone/internal_api/endpoint_schema_type'

module Moonstone
  module InternalAPI
    class ControllerEndpointSchemaType < Moonstone::Object

      field :name, type: :string
      field :endpoint, type: EndpointSchemaType

    end
  end
end
