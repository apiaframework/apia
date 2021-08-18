# frozen_string_literal: true

require 'apia/object'
require 'apia/schema/authenticator_schema_type'
require 'apia/schema/controller_endpoint_schema_type'

module Apia
  module Schema
    class ControllerSchemaType < Apia::Object

      no_schema

      field :id, type: :string
      field :name, type: :string, null: true
      field :description, type: :string, null: true
      field :authenticator, type: :string, null: true do
        backend { |c| c.authenticator&.definition&.id }
      end
      field :endpoints, type: [ControllerEndpointSchemaType] do
        backend do |c|
          c.endpoints.each_with_object([]) do |(key, endpoint), array|
            next unless endpoint.definition.schema?

            array << {
              name: key.to_s,
              endpoint: endpoint.definition.id
            }
          end
        end
      end

    end
  end
end
