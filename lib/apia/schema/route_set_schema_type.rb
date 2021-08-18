# frozen_string_literal: true

require 'apia/schema/route_schema_type'
require 'apia/schema/route_group_schema_type'
module Apia
  module Schema
    class RouteSetSchemaType < Apia::Object

      no_schema

      field :routes, [RouteSchemaType] do
        backend do |o|
          o.routes.select { |r| r.group&.schema? && r.endpoint&.definition&.schema? }
        end
      end

      field :groups, [RouteGroupSchemaType] do
        backend do |o|
          o.groups.select { |g| g.schema? }
        end
      end

    end
  end
end
