# frozen_string_literal: true

require 'rapid/object'
require 'rapid/internal_api/authenticator_schema_type'
require 'rapid/internal_api/api_controller_schema_type'

module Rapid
  module InternalAPI
    class APISchemaType < Rapid::Object

      field :id, type: :string
      field :name, type: :string, nil: true
      field :description, type: :string, nil: true

      field :authenticator, type: AuthenticatorSchemaType, nil: true do
        backend { |api| api.authenticator&.definition }
      end

      field :controllers, type: [APIControllerSchemaType] do
        backend do |api|
          api.controllers.map do |key, c|
            {
              name: key.to_s,
              controller: c.definition
            }
          end
        end
      end

    end
  end
end
