# frozen_string_literal: true

require 'moonstone/object'
require 'moonstone/internal_api/error_schema_type'

module Moonstone
  module InternalAPI
    class AuthenticatorSchemaType < Moonstone::Object

      field :id, type: :string
      field :name, type: :string, nil: true
      field :description, type: :string, nil: true
      field :type, type: :string
      field :potential_errors, type: [ErrorSchemaType] do
        backend { |a| a.potential_errors.map(&:definition) }
      end

    end
  end
end
