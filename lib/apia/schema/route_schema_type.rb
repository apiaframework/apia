# frozen_string_literal: true

require 'apia/schema/request_method_enum'

module Apia
  module Schema
    class RouteSchemaType < Apia::Object

      no_schema

      field :path, type: :string

      field :request_method, type: RequestMethodEnum do
        backend { |route| route.request_method }
      end

      field :controller, type: :string, null: true do
        backend { |route| route.controller&.definition&.id }
      end

      field :endpoint, type: :string, null: true do
        backend { |route| route.endpoint&.definition&.id }
      end

      field :group, type: :string, null: true do
        backend { |route| route.group&.id }
      end

    end
  end
end
