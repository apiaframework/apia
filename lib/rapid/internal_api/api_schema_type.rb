# frozen_string_literal: true

require 'rapid/object'
require 'rapid/internal_api/authenticator_schema_type'
require 'rapid/internal_api/api_controller_schema_type'
require 'rapid/internal_api/type_schema_polymorph'

module Rapid
  module InternalAPI
    class APISchemaType < Rapid::Object

      field :id, type: :string do
        backend { |api| api.definition.id }
      end

      field :name, type: :string, nil: true do
        backend { |api| api.definition.name }
      end

      field :description, type: :string, nil: true do
        backend { |api| api.definition.description }
      end

      field :authenticator, type: AuthenticatorSchemaType, nil: true do
        backend { |api| api.definition&.authenticator&.definition }
      end

      field :controllers, type: [APIControllerSchemaType] do
        backend do |api|
          api.definition&.controllers.map do |key, c|
            {
              name: key.to_s,
              controller: c.definition
            }
          end
        end
      end

      field :types, type: [TypeSchemaPolymorph] do
        backend do |api|
          api.objects.select do |o|
            [Rapid::Object, Rapid::Scalar, Rapid::Enum, Rapid::Polymorph].any? { |t| o.ancestors.include?(t) }
          end.map(&:definition)
        end
      end

    end
  end
end
