# frozen_string_literal: true

require 'rapid/schema/enum_value_schema_type'

module Rapid
  module Schema
    class EnumSchemaType < Rapid::Object

      no_schema

      field :id, type: :string
      field :name, type: :string, null: true
      field :description, type: :string, null: true
      field :values, type: [EnumValueSchemaType] do
        backend { |e| e.values.values }
      end

    end
  end
end
