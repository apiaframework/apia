# frozen_string_literal: true

require 'apia/object'
require 'apia/schema/error_schema_type'

module Apia
  module Schema
    class AuthenticatorSchemaType < Apia::Object

      no_schema

      field :id, type: :string
      field :name, type: :string, null: true
      field :description, type: :string, null: true
      field :type, type: :string
      field :potential_errors, type: [:string] do
        backend { |a| a.potential_errors.map { |e| e.definition.id } }
      end

    end
  end
end
