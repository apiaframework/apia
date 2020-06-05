# frozen_string_literal: true

require 'rapid/schema/request_method_enum'

module Rapid
  module Schema
    class RouteSchemaType < Rapid::Object

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
