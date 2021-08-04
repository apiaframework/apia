# frozen_string_literal: true

require 'apia/object'
require 'apia/schema/controller_schema_type'

module Apia
  module Schema
    class APIControllerSchemaType < Apia::Object

      no_schema

      field :name, type: :string
      field :controller, type: :string

    end
  end
end
