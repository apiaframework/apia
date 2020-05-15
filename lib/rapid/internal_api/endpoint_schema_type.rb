# frozen_string_literal: true

require 'rapid/object'
require 'rapid/internal_api/authenticator_schema_type'
require 'rapid/internal_api/field_schema_type'
require 'rapid/internal_api/argument_set_schema_type'

module Rapid
  module InternalAPI
    class EndpointSchemaType < Rapid::Object

      field :id, type: :string
      field :name, type: :string, nil: true
      field :description, type: :string, nil: true
      field :authenticator, type: AuthenticatorSchemaType, nil: true do
        backend { |e| e.authenticator&.definition }
      end
      field :argument_set, type: ArgumentSetSchemaType do
        backend { |e| e.argument_set.definition }
      end
      field :fields, type: [FieldSchemaType] do
        backend { |e| e.fields.values }
      end

    end
  end
end
