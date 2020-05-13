# frozen_string_literal: true

require 'moonstone/type'
require 'moonstone/internal_api/authenticator_schema_type'
require 'moonstone/internal_api/api_controller_schema_type'

module Moonstone
  module InternalAPI
    class APISchemaType < Moonstone::Type
      field :name, type: :string

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
