# frozen_string_literal: true

require 'rapid/object'
require 'rapid/internal_api/controller_schema_type'

module Rapid
  module InternalAPI
    class APIControllerSchemaType < Rapid::Object

      no_schema

      field :name, type: :string
      field :controller, type: :string

    end
  end
end
