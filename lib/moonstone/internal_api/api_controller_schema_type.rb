# frozen_string_literal: true

require 'moonstone/object'
require 'moonstone/internal_api/controller_schema_type'

module Moonstone
  module InternalAPI
    class APIControllerSchemaType < Moonstone::Object

      field :name, type: :string
      field :controller, type: ControllerSchemaType

    end
  end
end
