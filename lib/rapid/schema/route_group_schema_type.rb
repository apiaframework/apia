# frozen_string_literal: true

require 'rapid/schema/request_method_enum'

module Rapid
  module Schema
    class RouteGroupSchemaType < Rapid::Object

      no_schema

      field :id, type: :string
      field :name, type: :string, null: true
      field :description, type: :string, null: true

      field :groups, type: [RouteGroupSchemaType]

    end
  end
end
