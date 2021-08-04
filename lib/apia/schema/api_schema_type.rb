# frozen_string_literal: true

require 'apia/object'
require 'apia/schema/authenticator_schema_type'
require 'apia/schema/api_controller_schema_type'
require 'apia/schema/object_schema_polymorph'
require 'apia/schema/route_set_schema_type'
require 'apia/schema/scope_type'

module Apia
  module Schema
    class APISchemaType < Apia::Object

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

      field :route_set, type: RouteSetSchemaType
      field :scopes, type: [ScopeType] do
        backend do |api|
          api.scopes.map { |k, v| v.merge(name: k) }
        end
      end

    end
  end
end
