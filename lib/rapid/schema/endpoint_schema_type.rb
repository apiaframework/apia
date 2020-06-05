# frozen_string_literal: true

require 'rapid/object'
require 'rapid/schema/authenticator_schema_type'
require 'rapid/schema/field_schema_type'
require 'rapid/schema/argument_set_schema_type'
require 'rapid/schema/error_schema_type'

module Rapid
  module Schema
    class EndpointSchemaType < Rapid::Object

      no_schema

      field :id, type: :string
      field :name, type: :string, null: true
      field :description, type: :string, null: true
      field :http_status, type: :integer, backend: :http_status_code
      field :authenticator, type: :string, null: true do
        backend { |e| e.authenticator&.definition&.id }
      end
      field :argument_set, type: ArgumentSetSchemaType do
        backend { |e| e.argument_set.definition }
      end
      field :fields, type: [FieldSchemaType] do
        backend { |e| e.fields.values }
      end
      field :potential_errors, type: [:string] do
        backend { |a| a.potential_errors.map { |e| e.definition.id } }
      end

    end
  end
end