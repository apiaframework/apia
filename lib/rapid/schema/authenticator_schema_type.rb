# frozen_string_literal: true

require 'rapid/object'
require 'rapid/schema/error_schema_type'

module Rapid
  module Schema
    class AuthenticatorSchemaType < Rapid::Object

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
