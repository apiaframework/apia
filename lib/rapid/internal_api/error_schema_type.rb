# frozen_string_literal: true

require 'rapid/object'
require 'rapid/internal_api/field_schema_type'

module Rapid
  module InternalAPI
    class ErrorSchemaType < Rapid::Object

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
