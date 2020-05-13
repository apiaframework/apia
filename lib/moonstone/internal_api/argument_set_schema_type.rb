# frozen_string_literal: true

require 'moonstone/type'
require 'moonstone/internal_api/argument_schema_type'

module Moonstone
  module InternalAPI
    class ArgumentSetSchemaType < Moonstone::Type
      field :name, type: :string
      field :arguments, type: [ArgumentSchemaType] do
        backend { |as| as.arguments.values }
      end
    end
  end
end
