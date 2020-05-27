# frozen_string_literal: true

require 'rapid/object'
require 'rapid/internal_api/authenticator_schema_type'
require 'rapid/internal_api/field_schema_type'
require 'rapid/internal_api/argument_set_schema_type'
require 'rapid/internal_api/http_method_enum'
require 'rapid/internal_api/error_schema_type'

module Rapid
  module InternalAPI
    class EndpointSchemaType < Rapid::Object

      no_schema

      field :id, type: :string
      field :name, type: :string, null: true
      field :description, type: :string, null: true
      field :http_status, type: :integer, backend: :http_status_code
      field :http_method, type: HTTPMethodEnum
      field :authenticator, type: AuthenticatorSchemaType, null: true do
        backend { |e| e.authenticator&.definition }
      end
      field :argument_set, type: ArgumentSetSchemaType do
        backend { |e| e.argument_set.definition }
      end
      field :fields, type: [FieldSchemaType] do
        backend { |e| e.fields.values }
      end
      field :potential_errors, type: [ErrorSchemaType] do
        backend { |a| a.potential_errors.map(&:definition) }
      end

    end
  end
end
