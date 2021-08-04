# frozen_string_literal: true

require 'apia/object'
require 'apia/schema/field_schema_type'

module Apia
  module Schema
    class ObjectSchemaType < Apia::Object

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
