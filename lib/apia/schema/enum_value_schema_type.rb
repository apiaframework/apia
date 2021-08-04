# frozen_string_literal: true

module Apia
  module Schema
    class EnumValueSchemaType < Apia::Object

      no_schema

      field :name, type: :string
      field :description, type: :string, null: true

    end
  end
end
