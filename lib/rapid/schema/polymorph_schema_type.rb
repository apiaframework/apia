# frozen_string_literal: true

require 'rapid/schema/polymorph_option_schema_type'

module Rapid
  module Schema
    class PolymorphSchemaType < Rapid::Object

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
