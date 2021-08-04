# frozen_string_literal: true

require 'apia/schema/request_method_enum'

module Apia
  module Schema
    class RouteGroupSchemaType < Apia::Object

      no_schema

      field :id, type: :string
      field :name, type: :string, null: true
      field :description, type: :string, null: true

      field :groups, type: [RouteGroupSchemaType]

    end
  end
end
