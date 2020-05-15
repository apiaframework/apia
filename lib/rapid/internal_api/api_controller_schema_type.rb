# frozen_string_literal: true

require 'rapid/object'
require 'rapid/internal_api/controller_schema_type'

module Rapid
  module InternalAPI
    class APIControllerSchemaType < Rapid::Object

      field :name, type: :string
      field :controller, type: ControllerSchemaType

    end
  end
end
