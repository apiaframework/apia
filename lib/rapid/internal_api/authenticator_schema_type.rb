# frozen_string_literal: true

require 'rapid/object'
require 'rapid/internal_api/error_schema_type'

module Rapid
  module InternalAPI
    class AuthenticatorSchemaType < Rapid::Object

      no_schema

      field :id, type: :string
      field :name, type: :string, null: true
      field :description, type: :string, null: true
      field :type, type: :string
      field :potential_errors, type: [ErrorSchemaType] do
        backend { |a| a.potential_errors.map(&:definition) }
      end

    end
  end
end
