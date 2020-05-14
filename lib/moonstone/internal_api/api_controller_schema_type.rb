# frozen_string_literal: true

require 'moonstone/type'
require 'moonstone/internal_api/controller_schema_type'

module Moonstone
  module InternalAPI
    class APIControllerSchemaType < Moonstone::Type

      field :name, type: :string
      field :controller, type: ControllerSchemaType

    end
  end
end
