# frozen_string_literal: true

require 'rapid/object'

module Rapid
  module Schema
    class FieldIncludeOptionsSchemaType < Rapid::Object

      no_schema

      field :all, type: :boolean
      field :spec, type: :string, null: true

    end
  end
end
