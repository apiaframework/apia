# frozen_string_literal: true

module Apia
  module Schema
    class ScalarSchemaType < Apia::Object

      no_schema

      field :id, type: :string
      field :name, type: :string, null: true
      field :description, type: :string, null: true

    end
  end
end
