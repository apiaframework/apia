# frozen_string_literal: true

require 'apia/object'
require 'apia/schema/argument_schema_type'

module Apia
  module Schema
    class ArgumentSetSchemaType < Apia::Object

      no_schema

      field :id, type: :string
      field :name, type: :string, null: true
      field :description, type: :string, null: true
      field :arguments, type: [ArgumentSchemaType] do
        backend { |as| as.arguments.values }
      end

    end
  end
end
