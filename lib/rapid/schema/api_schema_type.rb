# frozen_string_literal: true

require 'rapid/object'
require 'rapid/schema/authenticator_schema_type'
require 'rapid/schema/api_controller_schema_type'
require 'rapid/schema/object_schema_polymorph'

module Rapid
  module Schema
    class APISchemaType < Rapid::Object

      no_schema

      condition { |api| api.schema? }

      field :id, type: :string do
        backend { |api| api.id }
      end

      field :name, type: :string, null: true do
        backend { |api| api.name }
      end

      field :description, type: :string, null: true do
        backend { |api| api.description }
      end

      field :authenticator, type: :string, null: true do
        backend { |api| api.authenticator&.definition&.id }
      end

      field :controllers, type: [APIControllerSchemaType] do
        backend do |api|
          api.controllers&.each_with_object([]) do |(key, c), array|
            next unless c.definition.schema?

            array << {
              name: key.to_s,
              controller: c.definition.id
            }
          end || []
        end
      end

    end
  end
end
