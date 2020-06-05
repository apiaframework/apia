# frozen_string_literal: true

require 'rapid/object'
require 'rapid/schema/controller_schema_type'

module Rapid
  module Schema
    class APIControllerSchemaType < Rapid::Object

      no_schema

      field :name, type: :string
      field :controller, type: :string

    end
  end
end
