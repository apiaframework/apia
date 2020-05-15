# frozen_string_literal: true

require 'moonstone/object'
require 'moonstone/internal_api/argument_schema_type'

module Moonstone
  module InternalAPI
    class ArgumentSetSchemaType < Moonstone::Object

      field :id, type: :string
      field :name, type: :string, nil: true
      field :description, type: :string, nil: true
      field :arguments, type: [ArgumentSchemaType] do
        backend { |as| as.arguments.values }
      end

    end
  end
end
