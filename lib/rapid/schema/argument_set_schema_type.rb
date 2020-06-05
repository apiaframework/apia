# frozen_string_literal: true

require 'rapid/object'
require 'rapid/schema/argument_schema_type'

module Rapid
  module Schema
    class ArgumentSetSchemaType < Rapid::Object

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
