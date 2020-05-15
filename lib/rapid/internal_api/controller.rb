# frozen_string_literal: true

require 'rapid/controller'
require 'rapid/internal_api/api_schema_type'

module Rapid
  module InternalAPI
    class Controller < Rapid::Controller

      description 'Provides endpoint to interrogate the API schema'
      endpoint :schema do
        description 'Returns a payload outlining the full schema of the API'
        field :host, type: :string
        field :namespace, type: :string
        field :schema, type: APISchemaType
        action do |request, response|
          response.add_field :schema, request.api
          response.add_field :namespace, request.namespace
          response.add_field :host, request.host
        end
      end

    end
  end
end
