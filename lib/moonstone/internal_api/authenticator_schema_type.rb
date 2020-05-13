# frozen_string_literal: true

require 'moonstone/type'
require 'moonstone/internal_api/error_schema_type'

module Moonstone
  module InternalAPI
    class AuthenticatorSchemaType < Moonstone::Type
      field :id, type: :string
      field :type, type: :string
      field :potential_errors, type: [ErrorSchemaType] do
        backend { |a| a.potential_errors.map(&:definition) }
      end
    end
  end
end
