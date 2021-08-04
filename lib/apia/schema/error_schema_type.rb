# frozen_string_literal: true

require 'apia/object'
require 'apia/schema/field_schema_type'

module Apia
  module Schema
    class ErrorSchemaType < Apia::Object

      no_schema

      field :id, type: :string
      field :name, type: :string, null: true
      field :description, type: :string, null: true
      field :code, type: :string, backend: proc { |s| s.code.to_s }
      field :http_status, type: :integer, backend: :http_status_code
      field :fields, type: [FieldSchemaType] do
        backend { |e| e.fields.values }
      end

    end
  end
end
