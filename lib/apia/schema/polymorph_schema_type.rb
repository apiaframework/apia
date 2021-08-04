# frozen_string_literal: true

require 'apia/schema/polymorph_option_schema_type'

module Apia
  module Schema
    class PolymorphSchemaType < Apia::Object

      no_schema

      field :id, type: :string
      field :name, type: :string, null: true
      field :description, type: :string, null: true
      field :options, type: [PolymorphOptionSchemaType] do
        backend { |o| o.options.values }
      end

    end
  end
end
