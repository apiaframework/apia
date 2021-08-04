# frozen_string_literal: true

require 'apia/object'

module Apia
  module Schema
    class FieldSpecOptionsSchemaType < Apia::Object

      no_schema

      field :all, type: :boolean
      field :spec, type: :string, null: true

    end
  end
end
