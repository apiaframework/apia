# frozen_string_literal: true

require 'rapid/internal_api/polymorph_option_schema_type'

module Rapid
  module InternalAPI
    class PolymorphSchemaType < Rapid::Object

      no_schema

      field :id, type: :string
      field :name, type: :string, nil: true
      field :description, type: :string, nil: true
      field :options, type: [PolymorphOptionSchemaType] do
        backend { |o| o.options.values }
      end

    end
  end
end
