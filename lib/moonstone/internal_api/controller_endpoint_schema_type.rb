# frozen_string_literal: true

require 'moonstone/type'
require 'moonstone/internal_api/endpoint_schema_type'

module Moonstone
  module InternalAPI
    class ControllerEndpointSchemaType < Moonstone::Type

      field :name, type: :string
      field :endpoint, type: EndpointSchemaType

    end
  end
end
