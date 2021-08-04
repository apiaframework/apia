# frozen_string_literal: true

module Apia
  module Schema
    class PolymorphOptionSchemaType < Apia::Object

      no_schema

      field :name, type: :string
      field :type, type: :string do
        backend { |a| a.type.id }
      end

    end
  end
end
