# frozen_string_literal: true

require 'rapid/object'
require 'rapid/internal_api/field_schema_type'

module Rapid
  module InternalAPI
    class ObjectSchemaType < Rapid::Object

      no_schema

      field :id, type: :string
      field :name, type: :string, null: true
      field :description, type: :string, null: true
      field :fields, type: [FieldSchemaType] do
        backend { |e| e.fields.values }
      end

    end
  end
end
