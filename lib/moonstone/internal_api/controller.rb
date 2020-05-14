# frozen_string_literal: true

require 'moonstone/controller'
require 'moonstone/internal_api/api_schema_type'

module Moonstone
  module InternalAPI
    class Controller < Moonstone::Controller

      description 'Provides endpoint to interrogate the API schema'
      endpoint :schema do
        description 'Returns a payload outlining the full schema of the API'
        field :host, type: :string
        field :namespace, type: :string
        field :schema, type: APISchemaType
        action do |request, response|
          response.add_field :schema, request.api.definition
          response.add_field :namespace, request.namespace
          response.add_field :host, request.host
        end
      end

    end
  end
end
