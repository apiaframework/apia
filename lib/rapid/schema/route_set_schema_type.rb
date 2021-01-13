# frozen_string_literal: true

require 'rapid/schema/route_schema_type'
require 'rapid/schema/route_group_schema_type'
module Rapid
  module Schema
    class RouteSetSchemaType < Rapid::Object

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
