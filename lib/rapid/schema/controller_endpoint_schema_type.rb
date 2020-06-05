# frozen_string_literal: true

require 'rapid/object'
require 'rapid/schema/endpoint_schema_type'

module Rapid
  module Schema
    class ControllerEndpointSchemaType < Rapid::Object

      no_schema

      field :name, type: :string
      field :endpoint, type: :string

    end
  end
end
