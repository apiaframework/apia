# frozen_string_literal: true

module Rapid
  module Schema
    class ScalarSchemaType < Rapid::Object

      no_schema

      field :id, type: :string
      field :name, type: :string, null: true
      field :description, type: :string, null: true

    end
  end
end
