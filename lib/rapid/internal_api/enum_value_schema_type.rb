# frozen_string_literal: true

module Rapid
  module InternalAPI
    class EnumValueSchemaType < Rapid::Object

      no_schema

      field :name, type: :string
      field :description, type: :string, null: true

    end
  end
end
