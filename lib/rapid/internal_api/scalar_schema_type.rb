# frozen_string_literal: true

module Rapid
  module InternalAPI
    class ScalarSchemaType < Rapid::Object

      no_schema

      field :id, type: :string
      field :name, type: :string, nil: true
      field :description, type: :string, nil: true

    end
  end
end
