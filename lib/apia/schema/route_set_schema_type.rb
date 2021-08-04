# frozen_string_literal: true

require 'apia/schema/route_schema_type'
require 'apia/schema/route_group_schema_type'
module Apia
  module Schema
    class RouteSetSchemaType < Apia::Object

      no_schema

      field :routes, [RouteSchemaType] do
        backend do |o|
          o.routes.select { |r| r.endpoint&.definition&.schema? }
        end
      end
      field :groups, [RouteGroupSchemaType]

    end
  end
end
