# frozen_string_literal: true

require 'rapid/object'
require 'rapid/internal_api/argument_schema_type'

module Rapid
  module InternalAPI
    class ArgumentSetSchemaType < Rapid::Object

      no_schema

      field :id, type: :string
      field :name, type: :string, nil: true
      field :description, type: :string, nil: true
      field :arguments, type: [ArgumentSchemaType] do
        backend { |as| as.arguments.values }
      end

    end
  end
end
