# frozen_string_literal: true

require 'apia/object'
require 'apia/schema/endpoint_schema_type'

module Apia
  module Schema
    class ControllerEndpointSchemaType < Apia::Object

      no_schema

      field :name, type: :string
      field :endpoint, type: :string

    end
  end
end
